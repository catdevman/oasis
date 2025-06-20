package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	// Command-line flags
	inputFile := flag.String("input", "CEDS_By_Domain.csv", "Input CSV file path")
	outputDir := flag.String("output-dir", "chunks", "Output directory for chunks")
	flag.Parse()

	// Create output directory
	if err := os.MkdirAll(*outputDir, 0755); err != nil {
		fmt.Fprintf(os.Stderr, "Error creating output directory: %v\n", err)
		os.Exit(1)
	}

	// Open input CSV
	file, err := os.Open(*inputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening input file: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	// Read CSV
	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading CSV: %v\n", err)
		os.Exit(1)
	}
	if len(records) < 1 {
		fmt.Fprintf(os.Stderr, "Error: CSV is empty\n")
		os.Exit(1)
	}

	// Get header
	header := records[0]
	domainIndex := -1
	for i, col := range header {
		if col == "Domain" {
			domainIndex = i
			break
		}
	}
	if domainIndex == -1 {
		fmt.Fprintf(os.Stderr, "Error: 'Domain' column not found for domain-based split\n")
		os.Exit(1)
	}

	// Split based on specified method
	splitByDomain(header, records[1:], domainIndex, *outputDir)

	fmt.Println("CSV splitting complete. Chunks saved in:", *outputDir)
}

// splitByDomain splits the CSV by Domain column
func splitByDomain(header []string, records [][]string, domainIndex int, outputDir string) {
	domainRecords := make(map[string][][]string)
	for _, record := range records {
		if len(record) <= domainIndex {
			continue // Skip malformed rows
		}
		domain := record[domainIndex]
		// Sanitize domain name for file path
		safeDomain := strings.ReplaceAll(string(domain), " ", "_")
		safeDomain = strings.ReplaceAll(safeDomain, "/", "_")
		domainRecords[safeDomain] = append(domainRecords[safeDomain], record)
	}

	for domain, recs := range domainRecords {

		// Write remaining records
		if len(recs) > 0 {
			writeChunk(header, recs, filepath.Join(outputDir, fmt.Sprintf("%s_Chunk.csv", domain)))
		}
	}
}

// writeChunk writes a chunk to a CSV file
func writeChunk(header []string, records [][]string, outputPath string) {
	file, err := os.Create(outputPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating output file %s: %v\n", outputPath, err)
		os.Exit(1)
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write header
	if err := writer.Write(header); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing header to %s: %v\n", outputPath, err)
		os.Exit(1)
	}

	// Write records
	for _, rec := range records {
		if err := writer.Write(rec); err != nil {
			fmt.Fprintf(os.Stderr, "Error writing record to %s: %v\n", outputPath, err)
			os.Exit(1)
		}
	}
}
