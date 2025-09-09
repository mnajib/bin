#!/usr/bin/env bash

# Input file (first argument if provided)
IFILE="${1:-ME-TRY-TO-UNDERSTAND-CONFIG.md}"

# Verify input file exists
if [[ ! -f "$IFILE" ]]; then
    echo "Error: Input file '$IFILE' not found" >&2
    exit 1
fi

#IFILE="ME-TRY-TO-UNDERSTAND-CONFIG.md"
#OFILE="ME-TRY-TO-UNDERSTAND-CONFIG.html"
OFILE="${IFILE%.md}.html" # Output file (same name with .html extension)
CSSFILE="${HOME}/bin/scrollable.css"

#OPTIONS=" "
#OPTIONS="${OPTIONS} --number-sections" # Adds automatic section numbering
#OPTIONS="${OPTIONS} --standalone" # Generates complete HTML document
#OPTIONS="${OPTIONS} --highlight-style=kate" # or pygments, breezeDark; syntax highlighting theme
#
# Use an array for options instead of string
OPTIONS=(
    "--number-sections"      # Adds automatic section numbering
    "--standalone"           # Generates complete HTML document
    "--highlight-style=kate" # Syntax highlighting theme
    "--css=$CSSFILE"         # Link CSS file
    "--metadata" "title=${IFILE%.md}"  # Set title from filename
)

embed_CSS_directly() {
  OPTIONS+=(
    "--include-in-header" <(echo '
      <style>
        /* Paste the final CSS here */

        /* Override Pandoc's code block styles */
        div.sourceCode {
          max-width: 100%;
          overflow: auto !important;
          margin: 1em 0;
          background: #f8f8f8 !important;
          border-radius: 4px;
          padding: 1em !important;
          box-shadow: 0 0 8px rgba(0,0,0,0.05);
          scrollbar-gutter: stable;
        }

        div.sourceCode pre.sourceCode {
          margin: 0 !important;
          padding: 0 !important;
          background: transparent !important;
          overflow: visible !important;
        }

        div.sourceCode code.sourceCode {
          display: block;
          padding: 0;
          background: none !important;
          white-space: pre !important;
        }

        /* Custom scrollbars */
        div.sourceCode::-webkit-scrollbar {
          height: 10px;
          width: 10px;
        }

        div.sourceCode::-webkit-scrollbar-thumb {
          background: #c1c1c1;
          border-radius: 10px;
        }

        div.sourceCode::-webkit-scrollbar-thumb:hover {
          background: #a8a8a8;
        }

        /* Firefox scrollbar */
        @supports (scrollbar-color: auto) {
          div.sourceCode {
            scrollbar-color: #c1c1c1 #f0f0f0;
            scrollbar-width: thin;
          }
        }

        /* Section numbering */
        body {
          counter-reset: section;
        }

        h1:before {
          counter-increment: section;
          content: counter(section) ". ";
        }

        h2:before {
          counter-increment: subsection;
          content: counter(section) "." counter(subsection) ". ";
        }

        h1 {
          counter-reset: subsection;
        }

        /* Override Pandoc's media query */
        @media screen {
          div.sourceCode {
            overflow: auto !important;
          }
        }

      </style>
    ')
  )
} # End embed_CSS_directly() { ... }

#embed_CSS_directly() {

# Generate HTML
echo "Converting $IFILE to $OFILE..."
#pandoc ME-TRY-TO-UNDERSTAND-CONFIG.md -o ME-TRY-TO-UNDERSTAND-CONFIG.html --number-sections
#pandoc "${IFILE}" -o "${OFILE}" "${OPTIONS}" --css="${CSSFILE}"
pandoc "${IFILE}" -o "${OFILE}" "${OPTIONS[@]}"

# Check success
if [[ $? -eq 0 ]]; then
    echo "Successfully generated $OFILE"
else
    echo "Conversion failed" >&2
    exit 2
fi
