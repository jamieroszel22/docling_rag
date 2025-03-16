@echo off
echo IBM Redbooks RAG System - Interactive Query Mode
echo ==============================================

REM Check if processed files exist
if not exist "C:\Users\jamie\OneDrive\Documents\Redbooks RAG\processed_redbooks\ollama\redbooks_ollama.jsonl" (
    echo Processed data not found.
    echo Please run process_redbooks.bat first.
    exit /b
)

REM Run the RAG system in interactive mode with granite3.2:8b-instruct-fp16 model
python ollama-rag-integration.py --input "C:\Users\jamie\OneDrive\Documents\Redbooks RAG\processed_redbooks\ollama\redbooks_ollama.jsonl" --model granite3.2:8b-instruct-fp16 --interactive
