import pandas as pd
import os

csv_file_path = os.path.join(os.path.dirname(__file__), 'budget.csv')

# Columns to remove
columns_to_drop = ['savings_perc', 'investments_gas'] # Based on your data headers

try:
    # Read the CSV file
    df = pd.read_csv(csv_file_path)

    # Check if columns exist before dropping
    existing_columns_to_drop = [col for col in columns_to_drop if col in df.columns]

    if existing_columns_to_drop:
        # Drop the specified columns
        df = df.drop(columns=existing_columns_to_drop)
        
        # Save the modified DataFrame back to the CSV, overwriting the original
        df.to_csv(csv_file_path, index=False)
        print(f"Successfully removed columns: {existing_columns_to_drop} from {csv_file_path}")
    else:
        print(f"None of the specified columns {columns_to_drop} were found in {csv_file_path}. No changes made.")

except FileNotFoundError:
    print(f"Error: {csv_file_path} not found.")
except Exception as e:
    print(f"An error occurred: {e}") 