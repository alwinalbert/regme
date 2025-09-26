from rest_framework import status
from rest_framework.decorators import api_view,action
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import BookingSerializer, ForgotPasswordSerializer, HallSerializer, ResetPasswordSerializer, UserRegisterSerializer, UserSerializer, BookingListSerializer
from .models import Hall, User,Booking
from rest_framework import viewsets, permissions

@api_view(['POST'])
def register_view(request):
    print("=== REGISTER VIEW CALLED ===")
    print(f"Request method: {request.method}")
    print(f"Request data: {request.data}")
    print(f"Content type: {request.content_type}")
    
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        print("Serializer is valid, creating user...")
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        response_data = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': UserSerializer(user).data
        }
        print(f"Returning success response: {response_data}")
        return Response(response_data, status=status.HTTP_201_CREATED)
    
    print(f"Serializer errors: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def login_view(request):
    print("=== LOGIN VIEW CALLED ===")
    email = request.data.get('email')
    password = request.data.get('password')
    print(f"Login attempt for email: {email}")
    
    try:
        user = User.objects.get(email=email)
        if user.check_password(password):
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user': UserSerializer(user).data
            })
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    except User.DoesNotExist:
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    
class HallViewSet(viewsets.ModelViewSet):
    queryset = Hall.objects.all()
    serializer_class = HallSerializer
    permission_classes = [permissions.IsAuthenticated]

class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        queryset = Booking.objects.all().order_by('-created_at')
        
        # Filter by hall_id if provided
        hall_id = self.request.query_params.get('hall_id', None)
        if hall_id is not None:
            queryset = queryset.filter(hall_id=hall_id)
        
        # Filter by user role
        if user.role in ['principal', 'admin']:
            return queryset
        else:
            return queryset.filter(requested_by=user)

    def get_serializer_class(self):
        if self.action == 'list':
            return BookingListSerializer
        return BookingSerializer

    def perform_create(self, serializer):
        request_type = self.request.data.get("request_type", "permissions")
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