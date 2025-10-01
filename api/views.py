from rest_framework import status
from rest_framework.decorators import api_view,action
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import BookingSerializer, ForgotPasswordSerializer, HallSerializer, ResetPasswordSerializer, UserRegisterSerializer, UserSerializer, BookingListSerializer
from .models import Hall, User,Booking
from rest_framework import viewsets, permissions
from django.core.mail import send_mail
from django.conf import settings
from .models import User, Hall, Booking, PasswordResetToken
from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

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
            email = serializer.validated_data['email']
            user = User.objects.get(email=email)
            
            # Delete any existing unused tokens for this user
            PasswordResetToken.objects.filter(user=user, is_used=False).delete()
            
            # Create new reset token
            reset_token = PasswordResetToken.objects.create(user=user)
            
            # Create reset URL
            reset_url = f"http://127.0.0.1:8000/api/reset-password-form/{reset_token.token}/"
            
            # Enhanced email template
            subject = 'Password Reset Request - Hall Booking System'
            html_message = f'''
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #6a5acd; padding: 20px; text-align: center;">
                    <h1 style="color: white; margin: 0;">Hall Booking System</h1>
                </div>
                
                <div style="padding: 30px; background-color: #f9f9f9;">
                    <h2 style="color: #333;">Password Reset Request</h2>
                    
                    <p>Hello <strong>{user.username}</strong>,</p>
                    
                    <p>We received a request to reset the password for your Hall Booking System account.</p>
                    
                    <p>Click the button below to reset your password:</p>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <a href="{reset_url}" 
                           style="background-color: #6a5acd; color: white; padding: 12px 30px; 
                                  text-decoration: none; border-radius: 5px; display: inline-block;">
                            Reset Password
                        </a>
                    </div>
                    
                    <p>Or copy and paste this link in your browser:</p>
                    <p style="word-break: break-all; background-color: #e9e9e9; padding: 10px;">
                        {reset_url}
                    </p>
                    
                    <p><strong>This link will expire in 1 hour.</strong></p>
                    
                    <p>If you did not request this password reset, please ignore this email and your password will remain unchanged.</p>
                    
                    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
                    
                    <p style="font-size: 12px; color: #666;">
                        Best regards,<br>
                        Hall Booking System Team
                    </p>
                </div>
            </body>
            </html>
            '''
            
            plain_message = f'''
            Password Reset Request - Hall Booking System
            
            Hello {user.username},
            
            We received a request to reset the password for your Hall Booking System account.
            
            Click or copy this link to reset your password:
            {reset_url}
            
            This link will expire in 1 hour.
            
            If you did not request this password reset, please ignore this email.
            
            Best regards,
            Hall Booking System Team
            '''
            
            try:
                from django.core.mail import EmailMultiAlternatives
                
                msg = EmailMultiAlternatives(
                    subject=subject,
                    body=plain_message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    to=[email]
                )
                msg.attach_alternative(html_message, "text/html")
                msg.send()
                
                return Response({
                    "message": "A password reset link has been sent to your email address. Please check your inbox."
                }, status=status.HTTP_200_OK)
                
            except Exception as e:
                print(f"Email sending failed: {e}")  # For debugging
                return Response({
                    "error": "Failed to send email. Please try again later."
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ResetPasswordView(APIView):
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({
                "message": "Your password has been reset successfully."
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@csrf_exempt
def reset_password_form_view(request, token):
    if request.method == 'GET':
        # Show HTML form
        html_form = f'''
        <!DOCTYPE html>
        <html>
        <head>
            <title>Reset Password - Hall Booking System</title>
            <style>
                body {{ font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }}
                .form-group {{ margin-bottom: 15px; }}
                label {{ display: block; margin-bottom: 5px; font-weight: bold; }}
                input {{ width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }}
                button {{ background: #6a5acd; color: white; padding: 12px 30px; border: none; border-radius: 4px; cursor: pointer; }}
                .success {{ color: green; }}
                .error {{ color: red; }}
            </style>
        </head>
        <body>
            <h2>Reset Your Password</h2>
            <form method="post">
                <div class="form-group">
                    <label for="password">New Password:</label>
                    <input type="password" id="password" name="new_password" required minlength="6">
                </div>
                <div class="form-group">
                    <label for="confirm_password">Confirm Password:</label>
                    <input type="password" id="confirm_password" name="confirm_password" required>
                </div>
                <button type="submit">Reset Password</button>
            </form>
            
            <script>
                document.querySelector('form').onsubmit = function(e) {{
                    const password = document.getElementById('password').value;
                    const confirm = document.getElementById('confirm_password').value;
                    if (password !== confirm) {{
                        alert('Passwords do not match!');
                        e.preventDefault();
                    }}
                }}
            </script>
        </body>
        </html>
        '''
        return HttpResponse(html_form)
    
    elif request.method == 'POST':
        # Handle form submission
        new_password = request.POST.get('new_password')
        try:
            reset_token = PasswordResetToken.objects.get(token=token, is_used=False)
            if reset_token.is_expired():
                return HttpResponse('<h2>Error: This reset link has expired.</h2>')
            
            user = reset_token.user
            user.set_password(new_password)
            user.save()
            
            reset_token.is_used = True
            reset_token.save()
            
            return HttpResponse('<h2>Success! Your password has been reset. You can now log in with your new password.</h2>')
        except PasswordResetToken.DoesNotExist:
            return HttpResponse('<h2>Error: Invalid or expired reset link.</h2>')