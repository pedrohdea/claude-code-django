from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """Custom user keyed by email."""

    email = models.EmailField(unique=True)
    bio = models.TextField(blank=True, default="")

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    def __str__(self) -> str:
        return self.email
