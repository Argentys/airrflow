#!/usr/bin/env bash
# Download germlines from the IMGT website
#
# Author:  Mohamed Uduman, Jason Anthony Vander Heiden
# Date:    2017.07.03
# Licence: AGPL-3
#
# Arguments:
#   -o = Output directory for downloaded files. Defaults to current directory.
#   -h = Display help.

# Default argument values
OUTDIR="."

# Print usage
usage () {
    echo "Usage: `basename $0` [OPTIONS]"
    echo "  -o  Output directory for downloaded files. Defaults to current directory."
    echo "  -h  This message."
}

# Get commandline arguments
while getopts "o:h" OPT; do
    case "$OPT" in
    o)  OUTDIR=$OPTARG
        OUTDIR_SET=true
        ;;
    h)  usage
        exit
        ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)  echo "Option -$OPTARG requires an argument" >&2
        exit 1
        ;;
    esac
done

# Info
REPERTOIRE="imgt"
DATE=$(date +"%Y.%m.%d")

# Associative array (for BASH v3) where keys are species folder names and values are query strings
SPECIES_QUERY=("human:Homo sapiens" \
               "mouse:Mus musculus" \
	       "alpaca:Vicugna pacos")
for species in "${SPECIES_QUERY[@]}"; do
    echo "$species"
done
# Associative array (for BASH v3) with species name replacements
SPECIES_REPLACE=('human:s/Homo sapiens/Homo_sapiens/g'
                 'mouse:s/Mus musculus/Mus_musculus/g'
		         'alpaca:s/Vicugna pacos/Vicugna_pacos/g')

FILE_PATH_TMP="${OUTDIR}/tmp"
mkdir -p $FILE_PATH_TMP

URL_AA="https://www.imgt.org/download/GENE-DB/IMGTGENEDB-ReferenceSequences.fasta-AA-WithGaps-F+ORF+inframeP"
URL_NT="https://www.imgt.org/download/GENE-DB/IMGTGENEDB-ReferenceSequences.fasta-nt-WithGaps-F+ORF+inframeP"
FILE_NAME_NT="${FILE_PATH_TMP}/${REPERTOIRE}.fasta"
FILE_NAME_AA="${FILE_PATH_TMP}/${REPERTOIRE}_aa.fasta"
wget -q $URL_NT -O $FILE_NAME_NT 
wget -q $URL_AA -O $FILE_NAME_AA


# Counter for loop iteration, used for getting the right values of SPECIES_REPLACE
COUNT=0
# For each species
for SPECIES in "${SPECIES_QUERY[@]}"
do
    KEY=${SPECIES%%:*}
    VALUE=${SPECIES#*:}
    REPLACE_VALUE=${SPECIES_REPLACE[$COUNT]#*:}
    echo "parsing ${KEY}:${VALUE} repertoires into ${OUTDIR}"

    # Download VDJ
    echo "|- VDJ regions"
    FILE_PATH="${OUTDIR}/${KEY}/vdj"
    FILE_PATH_AA="${OUTDIR}/${KEY}/vdj_aa"
    mkdir -p $FILE_PATH $FILE_PATH_AA

    # VDJ Ig
    echo "|---- Ig"
    for CHAIN in IGHV IGHD IGHJ IGKV IGKJ IGLV IGLJ
    do
        FILE_NAME="${FILE_PATH}/${REPERTOIRE}_${KEY}_${CHAIN}.fasta"
        parse_fasta.py $FILE_NAME_NT $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # V amino acid for Ig
    for CHAIN in IGHV IGKV IGLV
    do
        FILE_NAME="${FILE_PATH_AA}/${REPERTOIRE}_aa_${KEY}_${CHAIN}.fasta"
        parse_fasta.py $FILE_NAME_AA $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # VDJ TCR
    echo "|---- TCR"
    for CHAIN in TRAV TRAJ TRBV TRBD TRBJ TRDV TRDD TRDJ TRGV TRGJ
    do
        FILE_NAME="${FILE_PATH}/${REPERTOIRE}_${KEY}_${CHAIN}.fasta"
        parse_fasta.py $FILE_NAME_NT $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # V amino acid for TCR
    for CHAIN in TRAV TRBV TRDV TRGV
    do
        FILE_NAME="${FILE_PATH_AA}/${REPERTOIRE}_aa_${KEY}_${CHAIN}.fasta"
        parse_fasta.py $FILE_NAME_AA $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # Download leaders
    echo "|- Spliced leader regions"
    FILE_PATH="${OUTDIR}/${KEY}/leader"
    mkdir -p $FILE_PATH

    # Leader Ig
    echo "|---- Ig"
    for CHAIN in IGH IGK IGL
    do
        FILE_NAME="${FILE_PATH}/${REPERTOIRE}_${KEY}_${CHAIN}L.fasta"
        parse_fasta.py $FILE_NAME_NT $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # Leader TCR
    echo "|---- TCR"
    for CHAIN in TRA TRB TRG TRD
    do
        FILE_NAME="${FILE_PATH}/${REPERTOIRE}_${KEY}_${CHAIN}L.fasta"
        parse_fasta.py $FILE_NAME_NT $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # Download constant regions
    echo "|- Spliced constant regions"
    FILE_PATH="${OUTDIR}/${KEY}/constant/"
    mkdir -p $FILE_PATH

    # Constant Ig
    echo "|---- Ig"
    for CHAIN in IGHC IGKC IGLC
    do
        FILE_NAME="${FILE_PATH}/${REPERTOIRE}_${KEY}_${CHAIN}.fasta"
        parse_fasta.py $FILE_NAME_NT $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    # Constant for TCR
    echo "|---- TCR"
    for CHAIN in TRAC TRBC TRGC TRDC
    do
        FILE_NAME="${FILE_PATH}/${REPERTOIRE}_${KEY}_${CHAIN}.fasta"
        parse_fasta.py $FILE_NAME_NT $CHAIN "$VALUE" > $FILE_NAME
        sed -i.bak "$REPLACE_VALUE" $FILE_NAME && rm $FILE_NAME.bak
    done

    echo ""
    ((COUNT++))
done

# Write download info
INFO_FILE=${OUTDIR}/IMGT.yaml
echo -e "source:  https://www.imgt.org/download/GENE-DB" > $INFO_FILE
echo -e "date:    ${DATE}" >> $INFO_FILE
echo -e "species:" >> $INFO_FILE
for Q in "${SPECIES_QUERY[@]}"
do
    echo -e "    - ${Q}" >> $INFO_FILE
done
