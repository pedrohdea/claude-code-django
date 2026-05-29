import pytest
from django.urls import reverse
from rest_framework.test import APIClient

from apps.accounts.models import User


@pytest.fixture
def user(db) -> User:
    return User.objects.create_user(
        username="alice", email="alice@example.com", password="supersecret123"
    )


@pytest.fixture
def auth_client(user: User) -> APIClient:
    client = APIClient()
    client.force_authenticate(user=user)
    return client


def test_health_is_public() -> None:
    res = APIClient().get(reverse("health"))
    assert res.status_code == 200
    assert res.json() == {"status": "ok"}


def test_create_and_list_item(auth_client: APIClient) -> None:
    create = auth_client.post(reverse("item-list"), {"title": "buy milk"})
    assert create.status_code == 201
    listing = auth_client.get(reverse("item-list"))
    assert listing.json()["count"] == 1
