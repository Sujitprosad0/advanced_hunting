#!/bin/bash

# Target URL or List of URLs
TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target_url_or_file>"
  exit 1
fi

# Define output directory
OUTPUT_DIR="output"
HTTPX_DIR="$OUTPUT_DIR/httpx"
GF_DIR="$OUTPUT_DIR/gf"
NUCLEI_DIR="$OUTPUT_DIR/nuclei"

# Delete old output files (if any)
echo "[*] Deleting old output files..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$HTTPX_DIR"
mkdir -p "$GF_DIR"
mkdir -p "$NUCLEI_DIR"

# 1. ParamSpider - Collect endpoints
echo "[*] Running ParamSpider..."
paramspider -d "$TARGET" -o "$OUTPUT_DIR/paramspider.txt"

# 2. LinkFinder - Find JS Links
echo "[*] Running LinkFinder..."
linkfinder -i "$OUTPUT_DIR/paramspider.txt" -o cli > "$OUTPUT_DIR/linkfinder.txt"

# 3. Katana - Collect URLs
echo "[*] Running Katana..."
katana -u "$TARGET" -o "$OUTPUT_DIR/katana.txt"

# 4. Waybackurls - Find archived URLs
echo "[*] Running Waybackurls..."
waybackurls "$TARGET" > "$OUTPUT_DIR/waybackurls.txt"

# 5. Arjun - Parameter brute force
echo "[*] Running Arjun..."
arjun -u "$TARGET" -o "$OUTPUT_DIR/arjun.txt"

# 6. GauPlus - Collect URLs
echo "[*] Running GauPlus..."
gauplus "$TARGET" > "$OUTPUT_DIR/gauplus.txt"

# 7. Merge all collected URLs into a single file
echo "[*] Merging all collected URLs..."
cat "$OUTPUT_DIR/paramspider.txt" "$OUTPUT_DIR/linkfinder.txt" "$OUTPUT_DIR/katana.txt" "$OUTPUT_DIR/waybackurls.txt" "$OUTPUT_DIR/arjun.txt" "$OUTPUT_DIR/gauplus.txt" > "$OUTPUT_DIR/all_urls.txt"
sort -u "$OUTPUT_DIR/all_urls.txt" -o "$OUTPUT_DIR/all_urls_unique.txt"

# 8. HTTPX - Check status codes (200, 300, 403, 404)
echo "[*] Running HTTPX..."
httpx -l "$OUTPUT_DIR/all_urls_unique.txt" -o "$HTTPX_DIR/httpx_output.txt" -status-code -silent

# 9. Separate URLs based on status codes
echo "[*] Separating URLs based on status codes..."
grep "200" "$HTTPX_DIR/httpx_output.txt" > "$HTTPX_DIR/200_urls.txt"
grep "300" "$HTTPX_DIR/httpx_output.txt" > "$HTTPX_DIR/300_urls.txt"
grep "403" "$HTTPX_DIR/httpx_output.txt" > "$HTTPX_DIR/403_urls.txt"
grep "404" "$HTTPX_DIR/httpx_output.txt" > "$HTTPX_DIR/404_urls.txt"

# 10. Clean URLs and remove unnecessary parts (sed command)
echo "[*] Cleaning URLs..."
sed 's/[[:space:]]*$/\n/' "$HTTPX_DIR/200_urls.txt" > "$HTTPX_DIR/200_urls_cleaned.txt"
sed 's/[[:space:]]*$/\n/' "$HTTPX_DIR/300_urls.txt" > "$HTTPX_DIR/300_urls_cleaned.txt"
sed 's/[[:space:]]*$/\n/' "$HTTPX_DIR/403_urls.txt" > "$HTTPX_DIR/403_urls_cleaned.txt"
sed 's/[[:space:]]*$/\n/' "$HTTPX_DIR/404_urls.txt" > "$HTTPX_DIR/404_urls_cleaned.txt"

# 11. Delete the old files after cleaning
echo "[*] Deleting old files from HTTPX URLs..."
rm -f "$HTTPX_DIR/200_urls.txt" "$HTTPX_DIR/300_urls.txt" "$HTTPX_DIR/403_urls.txt" "$HTTPX_DIR/404_urls.txt"

# 12. GF Patterns - Run GF patterns on 200 status URLs
echo "[*] Running GF patterns on 200 URLs..."
GF_PATTERNS=(
  "xss"
  "sqli"
  "lfi"
  "ssrf"
  "rce"
  "xss-blind"
  "sqli-blind"
  "lfi-blind"
  "rce-blind"
  "bypass-auth"
  "idn-hostname"
  "csrf"
  "command-injection"
  "remote-file-inclusion"
  "websocket"
)

# Loop through each GF pattern
for pattern in "${GF_PATTERNS[@]}"; do
  echo "[*] Running GF $pattern pattern..."
  gf "$pattern" < "$HTTPX_DIR/200_urls_cleaned.txt" > "$GF_DIR/gf_$pattern.txt"
done

# 13. Merge and deduplicate all GF pattern results
echo "[*] Merging and removing duplicates from GF patterns..."
cat "$GF_DIR/gf_"*.txt > "$GF_DIR/all_gf_patterns.txt"
sort -u "$GF_DIR/all_gf_patterns.txt" -o "$GF_DIR/all_gf_patterns_unique.txt"

# 14. SecretFinder - Find secrets in 200 status URLs
echo "[*] Running SecretFinder on 200 status URLs..."
while IFS= read -r url; do
    secretfinder -i "$url" -o cli >> "$OUTPUT_DIR/secrets_200.txt"
done < "$HTTPX_DIR/200_urls_cleaned.txt"

# 15. Nuclei - Run Nuclei templates
echo "[*] Running Nuclei..."
nuclei -l "$HTTPX_DIR/200_urls_cleaned.txt" -t cves/ -o "$NUCLEI_DIR/nuclei_cves.txt"
nuclei -l "$HTTPX_DIR/200_urls_cleaned.txt" -t misconfiguration/ -o "$NUCLEI_DIR/nuclei_misconfig.txt"
nuclei -l "$HTTPX_DIR/200_urls_cleaned.txt" -t exposures/ -o "$NUCLEI_DIR/nuclei_exposures.txt"
nuclei -l "$HTTPX_DIR/200_urls_cleaned.txt" -t default-logins/ -o "$NUCLEI_DIR/nuclei_default_logins.txt"
nuclei -l "$HTTPX_DIR/200_urls_cleaned.txt" -t takeovers/ -o "$NUCLEI_DIR/nuclei_takeovers.txt"

# 16. Delete unnecessary files
echo "[*] Deleting unnecessary files..."
rm -f "$OUTPUT_DIR/paramspider.txt" "$OUTPUT_DIR/linkfinder.txt" "$OUTPUT_DIR/katana.txt" "$OUTPUT_DIR/waybackurls.txt" "$OUTPUT_DIR/arjun.txt" "$OUTPUT_DIR/gauplus.txt"
rm -f "$OUTPUT_DIR/all_urls.txt" "$OUTPUT_DIR/all_urls_unique.txt" "$OUTPUT_DIR/httpx_output.txt"

# 17. Final Output
echo "[*] Script execution completed!"
echo "[*] Check the output directory: $OUTPUT_DIR"
echo "[*] Files saved:"
echo "  - $HTTPX_DIR/httpx_output.txt"
echo "  - $HTTPX_DIR/200_urls_cleaned.txt"
echo "  - $HTTPX_DIR/300_urls_cleaned.txt"
echo "  - $HTTPX_DIR/403_urls_cleaned.txt"
echo "  - $HTTPX_DIR/404_urls_cleaned.txt"
echo "  - $GF_DIR/gf_*.txt"
echo "  - $GF_DIR/all_gf_patterns_unique.txt"
echo "  - $OUTPUT_DIR/secrets_200.txt"
echo "  - $NUCLEI_DIR/nuclei_*.txt"
