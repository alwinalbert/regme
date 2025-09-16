from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Hall, Booking
from .serializers import HallSerializer, BookingSerializer
from rest_framework import generics
from django.contrib.auth import get_user_model
from .serializers import UserRegisterSerializer
from .serializers import BookingCalendarSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import ForgotPasswordSerializer, ResetPasswordSerializer



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
        request_type=self.request.data.get("request_type","permissions")
        status_value = "reserved" if request_type == "reserve" else "pending"
        serializer.save(requested_by=self.request.user, request_type=request_type, status=status_value)

    @action(detail=True, methods=['post'])
    def approve_hall(self, request, pk=None):
        booking = self.get_object()
        if request.user.role == 'hall_incharge':
            booking.status = 'hall_approved'
            booking.save()
        return Response({'status': booking.status})
    
    @action(detail=True, methods=["post"])
    def suggest(self, request, pk=None):
        booking = self.get_object()
        remark = request.data.get("staff_remark", "")
        booking.staff_remark = remark
        # Keep status as pending but attach suggestion
        booking.save()
        return Response({"status": "pending_with_suggestion", "remark": remark})

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
class ForgotPasswordView(APIView):
    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            # ✅ Later: send email with token
            return Response({"message": "Password reset link sent (simulated)."}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ResetPasswordView(APIView):
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Password has been reset."}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)