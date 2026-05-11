from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from advisor.prolog_engine import PrologAdvisor
from .serializers import CourseSerializer, CourseDetailSerializer

class CourseListView(APIView):
    """
    List all courses, optionally filtered by level, difficulty, or category.
    """
    def get(self, request):
        advisor = PrologAdvisor()
        courses = advisor.get_all_courses()
        
        # Filtering
        level = request.query_params.get('level')
        difficulty = request.query_params.get('difficulty')
        category = request.query_params.get('category')
        
        if level:
            courses = [c for c in courses if str(c['level']) == level]
        if difficulty:
            courses = [c for c in courses if c['difficulty'] == difficulty]
        if category:
            courses = [c for c in courses if c['category'] == category]
            
        serializer = CourseSerializer(courses, many=True)
        return Response(serializer.data)

class CourseDetailView(APIView):
    """
    Get details for a single course.
    """
    def get(self, request, code):
        advisor = PrologAdvisor()
        course = advisor.get_course_detail(code)
        if not course:
            return Response({"error": "Course not found"}, status=status.HTTP_404_NOT_FOUND)
            
        serializer = CourseDetailSerializer(course)
        return Response(serializer.data)

class CategoryListView(APIView):
    """
    List all unique categories.
    """
    def get(self, request):
        advisor = PrologAdvisor()
        categories = advisor.get_categories()
        return Response(categories)
    
