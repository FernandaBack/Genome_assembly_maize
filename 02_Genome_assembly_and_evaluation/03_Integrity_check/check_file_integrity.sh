#!/usr/bin/env bash
# Detect silent filesystem corruption (blocks of null bytes, 4 MiB aligned).
# seqkit stats does NOT detect this — a damaged FASTA still parses normally.
# Usage: bash check_file_integrity.sh file1.fa file2.fastq.gz ...
for F in "$@"; do
    case "$F" in
      *.gz) pigz -t "$F" 2>/dev/null && echo "OK      $F" || echo "BROKEN  $F (invalid deflate data)";;
      *)    N=$(tr -dc '\000' < "$F" | wc -c)
            [ "$N" -eq 0 ] && echo "OK      $F" || echo "BROKEN  $F ($N null bytes)";;
    esac
done
# Keep md5 manifests of important results:  md5sum results/* > MANIFEST.md5
