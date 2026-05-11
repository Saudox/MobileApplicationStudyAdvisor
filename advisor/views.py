from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .prolog_engine import PrologAdvisor
from .serializers import RecommendationRequestSerializer, EligibilityRequestSerializer, StatsRequestSerializer
from courses.serializers import CourseSerializer

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
