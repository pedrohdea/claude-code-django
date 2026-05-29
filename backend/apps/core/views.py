from django.db.models import QuerySet
from rest_framework import permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.request import Request
from rest_framework.response import Response

from .models import Item
from .serializers import ItemSerializer


@api_view(["GET"])
@permission_classes([permissions.AllowAny])
def health(request: Request) -> Response:
    return Response({"status": "ok"})


class ItemViewSet(viewsets.ModelViewSet):
    serializer_class = ItemSerializer

    def get_queryset(self) -> QuerySet[Item]:
        return Item.objects.filter(owner=self.request.user)

    def perform_create(self, serializer: ItemSerializer) -> None:
        serializer.save(owner=self.request.user)
