from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    due_date: date
    status: str = Field("To-Do", pattern="^(To-Do|In Progress|Done)$")
    blocked_by_id: Optional[int] = None
    is_recurring: bool = False
    recurrence_type: Optional[str] = None # "Daily", "Weekly"

class TaskCreate(TaskBase):
    pass

class TaskUpdate(TaskBase):
    pass

class Task(TaskBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class PaginatedTasks(BaseModel):
    total: int
    tasks: list[Task]
