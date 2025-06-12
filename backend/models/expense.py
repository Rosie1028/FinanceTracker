from datetime import datetime
from typing import List
from sqlalchemy import Column, Integer, Float, DateTime, String, Table, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

# Association table for expense categories
expense_category = Table(
    'expense_category',
    Base.metadata,
    Column('expense_id', Integer, ForeignKey('expenses.id')),
    Column('category_id', Integer, ForeignKey('categories.id'))
)

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    description = Column(String, nullable=True)
    expenses = relationship("Expense", secondary=expense_category, back_populates="categories")

class Expense(Base):
    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float, nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    description = Column(String, nullable=True)
    categories = relationship("Category", secondary=expense_category, back_populates="expenses") 