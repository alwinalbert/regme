from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserRegisterSerializer, UserSerializer
from .models import User

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