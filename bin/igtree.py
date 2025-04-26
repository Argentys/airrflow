#!/usr/bin/env python3

import pandas as pd
import sys

from collections import defaultdict
pd.set_option('display.max_colwidth', None)  # Show full content of each column
pd.set_option('display.width', None)         # Don't wrap output to fit terminal width

df2 = pd.read_csv(sys.argv[1], delimiter='\t')
df = pd.read_csv(sys.argv[2], delimiter='\t')
df = df.sort_values('clone_id')



import collections

def check_reachability(start_node, target_node, graph):
    """
    Checks if target_node is reachable from start_node using BFS.
    Returns True if reachable (path length >= 1), False otherwise.
    """
    if start_node == target_node: # Path must have length > 0 for our check
        return False
    queue = collections.deque([start_node])
    visited = {start_node}
    while queue:
        current_node = queue.popleft()
        # Use graph.get to handle nodes without outgoing edges
        for neighbor in graph.get(current_node, []):
            if neighbor == target_node:
                return True
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    return False

def filter_graph_by_longer_paths(graph):
    """
    Filters a graph represented as a dictionary (parent: [children]).

    Removes a direct child 'C' from parent 'P's list if any path
    P -> Intermediate -> ... -> C exists in the original graph.

    Args:
        graph: A dictionary where keys are nodes and values are lists
               of their direct children.

    Returns:
        A new dictionary representing the filtered graph.
    """
    # Use a standard dict for the result this time
    filtered_graph = {}
    # Get all nodes that appear anywhere in the graph
    all_nodes = set(graph.keys())
    for children in graph.values():
        all_nodes.update(children)

    # Iterate through each parent and its original direct children
    for parent, children in graph.items():
        children_to_keep = []
        # Make a copy of children list to iterate while potentially modifying
        original_children = list(children)

        for child in original_children:
            found_longer_path = False
            # Check paths starting from *other* direct children of the parent
            for intermediate_child in original_children:
                # Path must go via an intermediate node first
                if intermediate_child == child:
                    continue

                # Check if 'child' is reachable from 'intermediate_child'
                # This confirms a path P -> intermediate_child -> ... -> child
                if check_reachability(intermediate_child, child, graph):
                    found_longer_path = True
                    break # Found one longer path, no need to check others

            # If no longer path was found through any intermediate child
            if not found_longer_path:
                children_to_keep.append(child)

        filtered_graph[parent] = children_to_keep

    # Ensure all nodes are present in the final output dict
    final_output = {}
    for node in all_nodes:
        # If node was a parent, use its list from filtered_graph (might be empty)
        # Otherwise, give it an empty list (if it only appeared as a child)
        final_output[node] = filtered_graph.get(node, [])

    return final_output

def get_max_depth_from_node(parent_to_children, node, memo=None, visited=None):
    """
    Calculate the maximum possible depth from a node in the digraph
    """
    if memo is None:
        memo = {}
    if visited is None:
        visited = set()
    if node in memo:
        return memo[node]
    if node in visited:
        return -1  # Avoid cycles
    
    visited.add(node)
    children = parent_to_children.get(node, [])
    if not children:
        memo[node] = 0
    else:
        memo[node] = 1 + max((get_max_depth_from_node(parent_to_children, child, memo, visited.copy())
                            for child in children), default=0)
    return memo[node]

def build_max_depth_branch(parent_to_children, root, visited=None):
    """
    Build a tree where all branches from the root extend to their maximal depth
    """
    if visited is None:
        visited = set()
    if root in visited:
        return None
    visited.add(root)
    
    tree = {root: []}
    children = parent_to_children.get(root, [])
    
    for child in children:
        if child not in visited:
            # Build the deepest possible subtree for this child
            subtree = build_max_depth_branch(parent_to_children, child, visited)
            if subtree:
                tree[root].append(subtree)
    
    return tree

def build_max_depth_forest(parent_to_children):
    """
    Build a forest where all branches in each tree have maximal depth
    """
    # Find all potential roots (nodes with no parents)
    all_children = set().union(*parent_to_children.values())
    all_parents = set(parent_to_children.keys())
    roots = all_parents - all_children
    # Pre-compute maximum depths for all nodes
    memo = {}
    for node in all_parents | all_children :
        get_max_depth_from_node(parent_to_children, node, memo)
    
    forest = []
    visited = set()
    
    for root in roots:
        if root not in visited:
            tree = build_max_depth_branch(parent_to_children, root, visited)
            if tree:
                forest.append(tree)
    
    return forest

# Helper function to print the forest
def print_forest(forest, level=0):
    for tree in forest:
        for node, children in tree.items():
            clns = df[df['sequence_id'] == node]['clone_id']
            clone_id = 0
            for cln in clns:
                clone_id= cln
            if level == 0:
                print("germline: "  + str(clone_id))
                seqs = df[df['sequence_id'] == node]['germline_alignment']
                for seq in seqs:
                   print(seq) 
            cnts = df[df['sequence_id'] == node]['collapse_count']
            str_cnt = ""
            for cnt in cnts:
                str_cnt = str_cnt + str(cnt) + " "


            cnts2 = df2[df2['sequence_id'] == node]['Redundancy']
            str_cnt2 = ""
            for cnt2 in cnts2:
                str_cnt2 = str_cnt2 + str(cnt2) + " "

            print("  " * level + "seqid:" + str(node) + " count:" + str_cnt + " redundancy:" + str_cnt2)
            seqs = df[df['sequence_id'] == node]['sequence_alignment']
            for seq in seqs:
                print(seq)
            for child in children:
                print_forest([child], level + 1)

# Helper function to calculate and print the depth of each tree

def calculate_depth(tree):
    if not tree:
        return (0, 0)  # (total_nodes, max_depth)
    total_nodes = 0
    max_depth = 0
    for node, children in tree.items():
        total_nodes = 1  # Count the current node
        if not children:
            return (1, 1)  # Leaf node: 1 node total, depth of 1
        # Recursively calculate for all children
        child_results = [calculate_depth(child) for child in children]
        # Add up total nodes from all children
        total_nodes += sum(child_nodes for child_nodes, _ in child_results)
        # Find max depth among children and add 1 for current level
        max_child_depth = max((depth for _, depth in child_results), default=0)
        max_depth = 1 + max_child_depth
    return (total_nodes, max_depth)


def print_forest_with_depth(forest):
    print("Forest of trees with all branches at maximal depth:")
    for i, tree in enumerate(forest):
        size,depth = calculate_depth(tree)
        if size < 3:
            continue
        print(f"\\\\")
        print(f"Tree {i + 1} (Max Depth: {depth} Size: {size}):")
        print_forest([tree])
    print(f"\\\\")

    
def CheckDistance(parent,child):
    flag1 = True
    flag2 = True
    for i in range(len(parent)):
        if parent[i] == child[i]:
            continue
        else:
            if parent[i] != '|':
                flag1 = False
            if child[i] != '|':
                flag2 = False
        if not flag1 and not flag2:
            break
    return flag1,flag2

def ProcessCluster(rr,ss,dd):
            j = 0
            k = len(rr[0])
            while j < k:
               flag = True
               for i in range(1,len(rr)):
                   if rr[i][j] != rr[i-1][j]:
                        flag = False
                        break
               if flag:
                   for i in range(len(rr)):
                       rr[i] = rr[i][:j] + rr[i][j+1:]
                   k = k - 1
               else:
                   j = j + 1
            if len(rr) <= 2000:
                for i in range(len(rr)):
                    for j in range(i+1,len(rr)):
                        flag1,flag2 = CheckDistance(rr[i],rr[j])
                        if flag1 and flag2:
                    #        print("identical ",ss[i],ss[j])
                            flag2 = False
                        if flag1: 
                            ar = dd.get(ss[i],[])
                            ar.append(ss[j])
                            dd[ss[i]] = ar
                        elif flag2:
                            ar = dd.get(ss[j],[])
                            ar.append(ss[i])
                            dd[ss[j]] = ar

def CreateString(b,c):
        r = ""
        for i in range(len(c)):
            if b[i] == c[i]:
                r = r + "|"
            else:
                r = r + c[i]
        return r
dd = {}
pd = -1
rr = []
ss = []
for index, row in df.iterrows():
        a = row["sequence_id"]
        b = row["germline_alignment"]
        c = row["sequence_alignment"]
        d = row["clone_id"]
        if pd != d and len(rr) > 0:
            ProcessCluster(rr,ss,dd)
            rr = []
            ss = []
        r = CreateString(b,c) 
        rr.append(r)
        ss.append(a)
        pd = d
if len(rr) > 0:
    ProcessCluster(rr,ss,dd)

filtered_dd = filter_graph_by_longer_paths(dd)
forest = build_max_depth_forest(filtered_dd)
print_forest_with_depth(forest)
