from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from database import get_db, engine
from models import expense as models_expense
from models import investment_and_saving as models_ias
from models import income as models_income
from schemas import expense as schemas_expense
from schemas import investment_and_saving as schemas_ias
from schemas import income as schemas_income
from crud import expense as crud_expense
from crud import investment_and_saving as crud_ias
from crud import income as crud_income

# Create database tables
models_expense.Base.metadata.create_all(bind=engine)
models_ias.Base.metadata.create_all(bind=engine)
models_income.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Finance Tracker API",
    description="Backend API for the Finance Tracker application",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to Finance Tracker API"}

# Expense endpoints
@app.post("/expenses/", response_model=schemas_expense.Expense)
def create_expense(expense: schemas_expense.ExpenseCreate, db: Session = Depends(get_db)):
    return crud_expense.create_expense(db=db, expense=expense)

@app.get("/expenses/", response_model=List[schemas_expense.Expense])
def read_expenses(
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    category_ids: Optional[List[int]] = None,
    db: Session = Depends(get_db)
):
    expenses = crud_expense.get_expenses(
        db,
        skip=skip,
        limit=limit,
        start_date=start_date,
        end_date=end_date,
        category_ids=category_ids
    )
    return expenses

@app.get("/expenses/{expense_id}", response_model=schemas_expense.Expense)
def read_expense(expense_id: int, db: Session = Depends(get_db)):
    db_expense = crud_expense.get_expense(db, expense_id=expense_id)
    if db_expense is None:
        raise HTTPException(status_code=404, detail="Expense not found")
    return db_expense

@app.put("/expenses/{expense_id}", response_model=schemas_expense.Expense)
def update_expense(
    expense_id: int,
    expense: schemas_expense.ExpenseCreate,
    db: Session = Depends(get_db)
):
    db_expense = crud_expense.update_expense(db, expense_id=expense_id, expense=expense)
    if db_expense is None:
        raise HTTPException(status_code=404, detail="Expense not found")
    return db_expense

@app.delete("/expenses/{expense_id}")
def delete_expense(expense_id: int, db: Session = Depends(get_db)):
    success = crud_expense.delete_expense(db, expense_id=expense_id)
    if not success:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"message": "Expense deleted successfully"}

# Category endpoints
@app.post("/categories/", response_model=schemas_expense.Category)
def create_category(category: schemas_expense.CategoryCreate, db: Session = Depends(get_db)):
    return crud_expense.create_category(db=db, category=category)

@app.get("/categories/", response_model=List[schemas_expense.Category])
def read_categories(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    categories = crud_expense.get_categories(db, skip=skip, limit=limit)
    return categories

# Saving endpoints
@app.post("/savings/", response_model=schemas_ias.Saving)
def create_saving(saving: schemas_ias.SavingCreate, db: Session = Depends(get_db)):
    return crud_ias.create_saving(db=db, saving=saving)

@app.get("/savings/", response_model=List[schemas_ias.Saving])
def read_savings(
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    return crud_ias.get_savings(db, skip=skip, limit=limit, start_date=start_date, end_date=end_date)

@app.get("/savings/{saving_id}", response_model=schemas_ias.Saving)
def read_saving(saving_id: int, db: Session = Depends(get_db)):
    db_saving = crud_ias.get_saving(db, saving_id=saving_id)
    if db_saving is None:
        raise HTTPException(status_code=404, detail="Saving entry not found")
    return db_saving

@app.put("/savings/{saving_id}", response_model=schemas_ias.Saving)
def update_saving(
    saving_id: int,
    saving: schemas_ias.SavingCreate,
    db: Session = Depends(get_db)
):
    db_saving = crud_ias.update_saving(db, saving_id=saving_id, saving=saving)
    if db_saving is None:
        raise HTTPException(status_code=404, detail="Saving entry not found")
    return db_saving

@app.delete("/savings/{saving_id}")
def delete_saving(saving_id: int, db: Session = Depends(get_db)):
    success = crud_ias.delete_saving(db, saving_id=saving_id)
    if not success:
        raise HTTPException(status_code=404, detail="Saving entry not found")
    return {"message": "Saving entry deleted successfully"}

# Investment endpoints
@app.post("/investments/", response_model=schemas_ias.Investment)
def create_investment(investment: schemas_ias.InvestmentCreate, db: Session = Depends(get_db)):
    return crud_ias.create_investment(db=db, investment=investment)

@app.get("/investments/", response_model=List[schemas_ias.Investment])
def read_investments(
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    return crud_ias.get_investments(db, skip=skip, limit=limit, start_date=start_date, end_date=end_date)

@app.get("/investments/{investment_id}", response_model=schemas_ias.Investment)
def read_investment(investment_id: int, db: Session = Depends(get_db)):
    db_investment = crud_ias.get_investment(db, investment_id=investment_id)
    if db_investment is None:
        raise HTTPException(status_code=404, detail="Investment entry not found")
    return db_investment

@app.put("/investments/{investment_id}", response_model=schemas_ias.Investment)
def update_investment(
    investment_id: int,
    investment: schemas_ias.InvestmentCreate,
    db: Session = Depends(get_db)
):
    db_investment = crud_ias.update_investment(db, investment_id=investment_id, investment=investment)
    if db_investment is None:
        raise HTTPException(status_code=404, detail="Investment entry not found")
    return db_investment

@app.delete("/investments/{investment_id}")
def delete_investment(investment_id: int, db: Session = Depends(get_db)):
    success = crud_ias.delete_investment(db, investment_id=investment_id)
    if not success:
        raise HTTPException(status_code=404, detail="Investment entry not found")
    return {"message": "Investment entry deleted successfully"}

# Income endpoints
@app.post("/incomes/", response_model=schemas_income.Income)
def create_income(income: schemas_income.IncomeCreate, db: Session = Depends(get_db)):
    return crud_income.create_income(db=db, income=income)

@app.get("/incomes/", response_model=List[schemas_income.Income])
def read_incomes(
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    return crud_income.get_incomes(db, skip=skip, limit=limit, start_date=start_date, end_date=end_date)

@app.get("/incomes/{income_id}", response_model=schemas_income.Income)
def read_income(income_id: int, db: Session = Depends(get_db)):
    db_income = crud_income.get_income(db, income_id=income_id)
    if db_income is None:
        raise HTTPException(status_code=404, detail="Income not found")
    return db_income

@app.put("/incomes/{income_id}", response_model=schemas_income.Income)
def update_income(
    income_id: int,
    income: schemas_income.IncomeCreate,
    db: Session = Depends(get_db)
):
    db_income = crud_income.update_income(db, income_id=income_id, income=income)
    if db_income is None:
        raise HTTPException(status_code=404, detail="Income not found")
    return db_income

@app.delete("/incomes/{income_id}")
def delete_income(income_id: int, db: Session = Depends(get_db)):
    success = crud_income.delete_income(db, income_id=income_id)
    if not success:
        raise HTTPException(status_code=404, detail="Income not found")
    return {"message": "Income deleted successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 