import threading
from pyswip import Prolog
from django.conf import settings

class PrologAdvisor:
    _instance = None
    _lock = threading.RLock()

    def __new__(cls):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super(PrologAdvisor, cls).__new__(cls)
                cls._instance._initialized = False
            return cls._instance

    def __init__(self):
        if self._initialized:
            return
        self.prolog = Prolog()
        # consult the prolog file
        prolog_path = str(settings.PROLOG_FILE)
        self.prolog.consult(prolog_path)
        self._initialized = True

    def query(self, q):
        """Helper to run a query with lock protection."""
        with self._lock:
            return list(self.prolog.query(q))

    def get_all_courses(self):
        """Returns a list of all courses as dictionaries."""
        results = self.query("course(ID, Name, Difficulty, Level)")
        courses = []
        for res in results:
            # We also want to attach the category to each course if possible
            # But the Prolog fact for category is category(ID, Cat)
            cat_results = self.query(f"category({res['ID']}, Category)")
            category = cat_results[0]['Category'] if cat_results else None
            
            courses.append({
                'code': res['ID'],
                'name': res['Name'],
                'difficulty': res['Difficulty'],
                'level': res['Level'],
                'category': category
            })
        return courses

    def get_course_detail(self, course_code):
        """Returns details for a single course, including prerequisites."""
        results = self.query(f"course({course_code}, Name, Difficulty, Level)")
        if not results:
            return None
        
        res = results[0]
        cat_results = self.query(f"category({course_code}, Category)")
        category = cat_results[0]['Category'] if cat_results else None
        
        # Get immediate prerequisites
        pre_results = self.query(f"prerequisite({course_code}, Pre)")
        prerequisites = [p['Pre'] for p in pre_results]
        
        return {
            'code': course_code,
            'name': res['Name'],
            'difficulty': res['Difficulty'],
            'level': res['Level'],
            'category': category,
            'prerequisites': prerequisites
        }

    def get_categories(self):
        """Returns a list of all unique categories."""
        results = self.query("category(_, Category)")
        categories = sorted(list(set(res['Category'] for res in results)))
        return categories

    def get_recommendations(self, completed_courses, interests):
        """
        Calculates recommendations based on completed courses and interests.
        Since it's stateless, we assert facts, query, and retract facts.
        """
        student_id = 'current_student'
        with self._lock:
            try:
                # 1. Assert facts
                for course in completed_courses:
                    self.prolog.assertz(f"student_completed({student_id}, {course})")
                for interest in interests:
                    self.prolog.assertz(f"love({student_id}, {interest})")
                
                # 2. Query
                results = self.prolog.query(f"recommend({student_id}, Course)")
                recommended_codes = [res['Course'] for res in results]
                
                # Enrich results with metadata
                recommendations = []
                for code in recommended_codes:
                    # We can use our existing helper (it will use the lock again, which is fine since we are in a 'with self._lock')
                    # Actually, we shouldn't call self.query inside here because of double lock if we are using the same lock.
                    # But Python's threading.Lock is not re-entrant. 
                    # Let's use an RLock if we want re-entrancy or just do direct queries.
                    
                    # Direct query for metadata to avoid deadlock
                    meta = list(self.prolog.query(f"course({code}, Name, Diff, Level)"))[0]
                    cat_res = list(self.prolog.query(f"category({code}, Cat)"))
                    cat = cat_res[0]['Cat'] if cat_res else None
                    
                    recommendations.append({
                        'code': code,
                        'name': meta['Name'],
                        'difficulty': meta['Diff'],
                        'level': meta['Level'],
                        'category': cat
                    })
                
                return recommendations
            finally:
                # 3. Retract facts
                self.prolog.retractall(f"student_completed({student_id}, _)")
                self.prolog.retractall(f"love({student_id}, _)")

    def get_eligible(self, completed_courses):
        """Returns all courses the student is eligible for, ignoring interests."""
        student_id = 'current_student'
        with self._lock:
            try:
                for course in completed_courses:
                    self.prolog.assertz(f"student_completed({student_id}, {course})")
                
                results = self.prolog.query(f"eligible({student_id}, Course)")
                eligible_codes = [res['Course'] for res in results]
                
                eligible_courses = []
                for code in eligible_codes:
                    meta = list(self.prolog.query(f"course({code}, Name, Diff, Level)"))[0]
                    cat_res = list(self.prolog.query(f"category({code}, Cat)"))
                    cat = cat_res[0]['Cat'] if cat_res else None
                    
                    eligible_courses.append({
                        'code': code,
                        'name': meta['Name'],
                        'difficulty': meta['Diff'],
                        'level': meta['Level'],
                        'category': cat
                    })
                
                return eligible_courses
            finally:
                self.prolog.retractall(f"student_completed({student_id}, _)")

    def get_prerequisite_tree(self, course_code):
        """Returns the full recursive prerequisite chain for a course."""
        # Simple recursive fetch
        visited = set()
        
        def fetch_pres(code):
            if code in visited:
                return []
            visited.add(code)
            
            pres = [p['Pre'] for p in self.query(f"prerequisite({code}, Pre)")]
            tree = []
            for p in pres:
                tree.append({
                    'code': p,
                    'prerequisites': fetch_pres(p)
                })
            return tree

        return fetch_pres(course_code)
