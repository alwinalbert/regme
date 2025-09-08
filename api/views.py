from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Hall, Booking
from .serializers import HallSerializer, BookingSerializer
from rest_framework import generics
from django.contrib.auth import get_user_model
from .serializers import UserRegisterSerializer
from .serializers import BookingCalendarSerializer


User = get_user_model()

class UserRegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserRegisterSerializer
    # Anyone can register (you can lock this down later if needed)
    permission_classes = []

class HallViewSet(viewsets.ModelViewSet):
    queryset = Hall.objects.all()
    serializer_class = HallSerializer
    permission_classes = [permissions.IsAuthenticated]

class BookingViewSet(viewsets.ModelViewSet):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        # Automatically set requesting user
        serializer.save(requested_by=self.request.user)

    @action(detail=True, methods=['post'])
    def approve_hall(self, request, pk=None):
        booking = self.get_object()
        if request.user.role == 'hall_incharge':
            booking.status = 'hall_approved'
            booking.save()
        return Response({'status': booking.status})

    @action(detail=True, methods=['post'])
    def approve_principal(self, request, pk=None):
        booking = self.get_object()
        if request.user.role == 'principal':
            booking.status = 'principal_approved'
            booking.save()
        return Response({'status': booking.status})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        booking = self.get_object()
        booking.status = 'rejected'
        booking.save()
        return Response({'status': booking.status})
    
    @action(detail=False, methods=["get"])
    def calendar(self, request):
        bookings = self.get_queryset()
        serializer = BookingCalendarSerializer(bookings, many=True)
        return Response(serializer.data)
