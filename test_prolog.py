import os
import django
import sys

# Setup django
sys.path.append('/media/samcro/New Volume/code/Projects/MobileApplicationStudyAdvisor')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from advisor.prolog_engine import PrologAdvisor

def test_prolog():
    print("Initializing PrologAdvisor...")
    advisor = PrologAdvisor()
    
    print("\nFetching all courses...")
    courses = advisor.get_all_courses()
    print(f"Found {len(courses)} courses.")
    if courses:
        print(f"Example course: {courses[0]}")
    
    print("\nFetching categories...")
    categories = advisor.get_categories()
    print(f"Categories: {categories}")
    
    print("\nTesting recommendations...")
    # Student completed math1 and loves math
    recs = advisor.get_recommendations(['math1'], ['math'])
    print(f"Recommendations for ['math1'] + ['math']: {[r['code'] for r in recs]}")
    
    print("\nTesting eligibility...")
    eligible = advisor.get_eligible(['math1'])
    print(f"Eligible for after ['math1']: {[e['code'] for e in eligible]}")

if __name__ == "__main__":
    try:
        test_prolog()
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
