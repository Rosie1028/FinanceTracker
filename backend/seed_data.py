from sqlalchemy.orm import Session
from models.expense import Category, Expense
from models.investment_and_saving import Saving, Investment
from models.income import Income
from datetime import datetime
import pandas as pd
import os
from crud import investment_and_saving as crud_ias

# Categories derived from CSV columns for expenses
CSV_EXPENSE_CATEGORIES = [
    "rent",
    "car",
    "car_insuranc",
    "health_insura",
    "groceries",
    "GFS",
    "education",
    "state",
    "house",
    "subscription",
    "gifts",
    "pets",
]

def seed_database(db: Session):
    # Define the path to the CSV file
    csv_file_path = os.path.join(os.path.dirname(__file__), 'budget.csv')

    # Read the CSV file using pandas
    try:
        df = pd.read_csv(csv_file_path)
    except FileNotFoundError:
        print(f"Error: budget.csv not found at {csv_file_path}")
        return

    # Create categories if they don't exist
    categories = {}
    for category_name_raw in CSV_EXPENSE_CATEGORIES:
        # Clean up category names from OCR if necessary
        category_name = category_name_raw.replace('_insuranc', ' Insurance').replace('_insura', ' Insurance').replace('_', ' ').title()
        category = db.query(Category).filter(Category.name == category_name).first()
        if not category:
            category = Category(name=category_name)
            db.add(category)
            db.flush() # Flush to get the ID
        categories[category_name_raw] = category # Map raw name to object

    # Process each row in the CSV
    for _, row in df.iterrows():
        # Get the month and year from the respective columns
        try:
            month_str = row.get('month')
            year_int = row.get('year')
            if month_str is None or year_int is None:
                 print(f"Skipping row: Missing 'month' or 'year' column.")
                 continue
            month = datetime(year=int(year_int), month=datetime.strptime(month_str, '%B').month, day=1)
        except Exception as e:
            print(f"Could not parse date from month='{month_str}', year='{year_int}'. Error: {e}")
            continue

        # Create expenses for each category
        for category_name_raw, category in categories.items():
            if category_name_raw in df.columns:
                amount = row[category_name_raw]
                if pd.notna(amount) and amount != 0:  # Only create if there's a value
                    expense = Expense(
                        amount=float(amount),
                        date=month,
                        description=f"{category.name} for {month.strftime('%B %Y')}",
                        categories=[category]
                    )
                    db.add(expense)

        # Create savings entry if exists
        if 'savings' in df.columns:
            savings_amount = row['savings']
            if pd.notna(savings_amount) and savings_amount != 0:
                saving = Saving(
                    amount=float(savings_amount),
                    date=month,
                    description=f"Savings for {month.strftime('%B %Y')}"
                )
                db.add(saving)

        # Create investment entry if exists
        if 'investments' in df.columns:
            investment_amount = row['investments']
            if pd.notna(investment_amount) and investment_amount != 0:
                investment = Investment(
                    amount=float(investment_amount),
                    date=month,
                    description=f"Investment for {month.strftime('%B %Y')}"
                )
                db.add(investment)

        # Create income entry if exists
        if 'income' in df.columns:
            income_amount = row['income']
            if pd.notna(income_amount) and income_amount != 0:
                income = Income(
                    amount=float(income_amount),
                    date=month,
                    description=f"Income for {month.strftime('%B %Y')}",
                    source="Salary"  # Default source, you can modify this based on your needs
                )
                db.add(income)

    # Commit all changes
    db.commit()

if __name__ == "__main__":
    from database import SessionLocal
    from models.expense import Base as ExpenseBase # Import Base from expense for table creation
    from models.investment_and_saving import Base as IASBase # Import Base from ias for table creation
    from models.income import Base as IncomeBase # Import Base from income for table creation
    from database import engine # Import engine to create tables

    # Create tables if they don't exist (includes Expense, Category, Saving, Investment, Income)
    ExpenseBase.metadata.create_all(bind=engine)
    IASBase.metadata.create_all(bind=engine)
    IncomeBase.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        seed_database(db)
        print("Database seeded successfully from budget.csv!")
    except Exception as e:
        db.rollback() # Rollback in case of error
        print(f"Error seeding database: {e}")
    finally:
        db.close() 