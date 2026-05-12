# pyrefly: ignore [missing-import]
from rest_framework.views import APIView
# pyrefly: ignore [missing-import]
from rest_framework.response import Response
# pyrefly: ignore [missing-import]
from rest_framework import status
from .prolog_engine import PrologAdvisor
# pyrefly: ignore [missing-import]
from .serializers import RecommendationRequestSerializer, EligibilityRequestSerializer, StatsRequestSerializer
# pyrefly: ignore [missing-import]
from courses.serializers import CourseSerializer
# pyrefly: ignore [missing-import]
from django.conf import settings
# pyrefly: ignore [missing-import]
from groq import Groq

class RecommendationView(APIView):
    """
    Get course recommendations based on completed courses and interests.
    """
    def post(self, request):
        serializer = RecommendationRequestSerializer(data=request.data)
        if serializer.is_valid():
            completed = serializer.validated_data.get('completed')
            interests = serializer.validated_data.get('interests')
            
            advisor = PrologAdvisor()
            recommendations = advisor.get_recommendations(completed, interests)
            
            return Response({
                "student_completed": completed,
                "interests": interests,
                "recommendations": recommendations
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class EligibilityView(APIView):
    """
    Get all courses the student is eligible for based on completed courses.
    """
    def post(self, request):
        serializer = EligibilityRequestSerializer(data=request.data)
        if serializer.is_valid():
            completed = serializer.validated_data.get('completed')
            
            advisor = PrologAdvisor()
            eligible_courses = advisor.get_eligible(completed)
            
            return Response({
                "student_completed": completed,
                "eligible_courses": eligible_courses
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PrerequisiteTreeView(APIView):
    """
    Get the full prerequisite tree for a specific course.
    """
    def get(self, request, code):
        advisor = PrologAdvisor()
        tree = advisor.get_prerequisite_tree(code)
        if not tree and not advisor.get_course_detail(code):
             return Response({"error": "Course not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(tree)

class StatsView(APIView):
    """
    Get progress statistics based on completed courses.
    """
    def post(self, request):
        serializer = StatsRequestSerializer(data=request.data)
        if serializer.is_valid():
            completed = serializer.validated_data.get('completed')
            
            advisor = PrologAdvisor()
            all_courses = advisor.get_all_courses()
            
            total_courses = len(all_courses)
            completed_count = len(completed)
            
            # Per level breakdown
            levels = {}
            for course in all_courses:
                lv = course['level']
                levels.setdefault(lv, {"total": 0, "completed": 0})
                levels[lv]["total"] += 1
                if course['code'] in completed:
                    levels[lv]["completed"] += 1
            
            return Response({
                "total_courses": total_courses,
                "completed_courses": completed_count,
                "percentage": round((completed_count / total_courses * 100), 2) if total_courses > 0 else 0,
                "levels": levels
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class AIChatView(APIView):
    def post(self, request):
        user_message = request.data.get('message', '')
        completed = request.data.get('completed', [])
        interests = request.data.get('interests', [])

        if not user_message.strip():
            return Response({"error": "Message cannot be empty"}, status=status.HTTP_400_BAD_REQUEST)

        # 1. Create the Groq client
        client = Groq(api_key=settings.GROQ_API_KEY)

        # 2. Build the context
        completed_str = ', '.join(completed) if completed else 'None yet'
        interests_str = ', '.join(interests) if interests else 'Not specified'

        system_prompt = f"""You are a Smart Study Advisor for Alexandria University's Computer & Systems Engineering (CSE) department.

Student profile:
- Completed courses: {completed_str}
- Interests: {interests_str}

The available course categories are: math, programming, hardware, theory, ai, systems, general.

Give helpful, specific, friendly advice about their studies. Keep it concise (3-5 sentences max).
If recommending courses, mention why they fit the student's interests and completed courses.
Do not use markdown formatting like ** or ## — use plain text only."""

        try:
            # 3. Call the Llama 3 model via Groq
            chat_completion = client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        "content": system_prompt
                    },
                    {
                        "role": "user",
                        "content": user_message
                    }
                ],
                model="llama-3.3-70b-versatile",
            )
            
            # 4. Extract and return the text
            reply_text = chat_completion.choices[0].message.content
            return Response({"reply": reply_text})
            
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)