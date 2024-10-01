import fastapi
import pydantic

print("Hello world!")


class MyClass(pydantic.BaseModel):
    def hello():
        print("Hello!")


class MyOtherClass:
    def __init__(self):
        print("Class")
