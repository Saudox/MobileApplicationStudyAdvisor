%%%%%%%%%%%%%%%%%%%%%%%%%% FACTS %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Dynamic predicates %%%%%%%

% These predicates will be asserted and retracted at runtime to represent the student's completed courses and interests Using Django
:- dynamic student_completed/2.
:- dynamic love/2.


%%%%%%% Course facts %%%%%%%
% course(id, display_name, difficulty, level)

% Level 0
course(math1,'Mathematics 1',easy,0).
course(mechanics1,'Mechanics 1',easy,0).
course(physics1,'Physics 1',easy,0).
course(eng_drawing1,'Engineering Drawing 1',easy,0).
course(manufacturing,'Fundamentals of Engineering & Manufacturing',easy,0).
course(math2,'Mathematics 2',easy,0).
course(mechanics2,'Mechanics 2',easy,0).
course(physics2,'Physics 2',easy,0).
course(eng_drawing2,'Engineering Drawing 2',easy,0).
course(eng_chemistry,'Engineering Chemistry',easy,0).
course(history_eng,'History of Engineering & Technology',easy,0).


% Level 1
course(computer_society1,'Computer & Society 1',easy,1).
course(linear_algebra,'Linear Algebra',medium,1).
course(probability,'Probability & Computer Applications',medium,1).
course(programming1,'Programming 1',easy,1).
course(logical_design,'Logical Digital Design',medium,1).
course(electrical_eng,'Fundamentals of Electrical Engineering',medium,1).
course(differential_eq,'Differential Equations',hard,1).
course(statistical_methods,'Statistical Methods for Computing',medium,1).
course(data_structures,'Data Structures',medium,1).
course(digital_systems,'Digital Systems Design',medium,1).
course(electronics,'Electronics & Circuits',medium,1).
course(computer_society2,'Computer & Society 2',easy,1).


% Level 2
course(numerical_analysis,'Numerical Analysis',hard,2).
course(discrete_structures,'Discrete Structures',hard,2).
course(programming2,'Programming 2',medium,2).
course(computer_org,'Computer Organization',hard,2).
course(hci,'Human Computer Interaction',easy,2).
course(general_culture,'General Culture',easy,2).
course(operations_research,'Operations Research & Optimization',hard,2).
course(ds_algorithms,'Data Structures & Algorithms',hard,2).
course(prog_paradigms,'Programming Languages Paradigms',hard,2).
course(control_systems,'Control Systems Fundamentals',hard,2).
course(operating_systems,'Operating Systems',hard,2).
course(technical_writing,'Technical Writing',easy,2).


% Level 3
course(algorithms,'Algorithm Design & Analysis',hard,3).
course(networks,'Computer Networks',hard,3).
course(software_eng,'Software Engineering',medium,3).
course(intro_ai,'Intro to AI & Machine Learning',hard,3).
course(databases,'Database Systems',medium,3).
course(innovation,'Innovation & Entrepreneurship',easy,3).
course(digital_control,'Digital Control & Modern Systems',hard,3).
course(embedded_systems,'Embedded Systems',hard,3).
course(computer_arch,'Computer Architecture',hard,3).
course(critical_thinking,'Critical Thinking',easy,3).



%%%%%%% Category facts %%%%%%%
% category(Course, Category)

% math
category(math1,math).
category(math2,math).
category(linear_algebra,math).
category(probability,math).
category(differential_eq,math).
category(statistical_methods,math).
category(numerical_analysis,math).
category(operations_research,math).


% programming
category(programming1,programming).
category(data_structures,programming).
category(programming2,programming).
category(prog_paradigms,programming).
category(algorithms,programming).
category(software_eng,programming).


% hardware
category(electrical_eng,hardware).
category(logical_design,hardware).
category(digital_systems,hardware).
category(electronics,hardware).
category(computer_org,hardware).
category(control_systems,hardware).
category(digital_control,hardware).
category(embedded_systems,hardware).
category(computer_arch,hardware).


% theory
category(discrete_structures,theory).
category(ds_algorithms,theory).


% ai
category(intro_ai,ai).


% systems
category(databases,systems).
category(operating_systems,systems).
category(networks,systems).


% general
category(mechanics1,general).
category(mechanics2,general).
category(physics1,general).
category(physics2,general).
category(eng_drawing1,general).
category(eng_drawing2,general).
category(manufacturing,general).
category(eng_chemistry,general).
category(history_eng,general).
category(computer_society1,general).
category(computer_society2,general).
category(hci,general).
category(general_culture,general).
category(technical_writing,general).
category(innovation,general).
category(critical_thinking,general).


%%%%%%%% Prerequisite facts %%%%%%%
% prerequisite(Course, RequiredFirst)

prerequisite(math2,math1).
prerequisite(mechanics2,mechanics1).
prerequisite(physics2,physics1).
prerequisite(eng_drawing2,eng_drawing1).

prerequisite(linear_algebra,math1).
prerequisite(probability,math1).
prerequisite(programming1,computer_society1).
prerequisite(logical_design,math1).
prerequisite(electrical_eng,physics1).
prerequisite(differential_eq,math2).
prerequisite(statistical_methods,math2).
prerequisite(computer_society2,computer_society1).


prerequisite(differential_eq,linear_algebra).
prerequisite(statistical_methods,probability).
prerequisite(data_structures,programming1).
prerequisite(digital_systems,logical_design).
prerequisite(electronics,electrical_eng).


prerequisite(hci, programming1).
prerequisite(numerical_analysis,differential_eq).
prerequisite(discrete_structures,data_structures).
prerequisite(programming2,data_structures).
prerequisite(computer_org,digital_systems).


prerequisite(operations_research,numerical_analysis).
prerequisite(ds_algorithms,discrete_structures).
prerequisite(prog_paradigms,programming2).
prerequisite(control_systems,computer_org).
prerequisite(operating_systems,control_systems).


prerequisite(algorithms,operations_research).
prerequisite(algorithms,ds_algorithms).
prerequisite(networks,ds_algorithms).
prerequisite(software_eng,prog_paradigms).
prerequisite(intro_ai,control_systems).
prerequisite(databases,operating_systems).


prerequisite(digital_control,algorithms).
prerequisite(embedded_systems,networks).
prerequisite(computer_arch,software_eng).


%%%%%%%%%%%%%%%%%%%%%%%%%% RULES %%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% prerequisite rule %%%%%%%
prerequisite_met(Student , Course) :-
    % not ( this course has a pre  AND student don't complete it )
    \+ ( prerequisite( Course , Pre ) , \+ student_completed( Student , Pre )).





%%%%%%% course not taken rule %%%%%%%
not_taken_yet(Student , Course) :-
    \+( student_completed( Student , Course )).





%%%%%%% eligible rule %%%%%%%
eligible(Student , Course) :-
    course(Course, _, _, _) , prerequisite_met(Student , Course) , not_taken_yet(Student , Course).





%%%%%%% student interest rule %%%%%%%
student_interest(Student , Course) :-
    category(Course , Category) , love(Student , Category).




%%%%%%% difficulty readiness rule %%%%%%%
ready_for_difficulty(_, Course) :-
    course(Course , _ , easy , _).

ready_for_difficulty(_, Course) :-
    course(Course , _ , medium , _).

% u must have completed at least one hard course to be ready for another hard course
ready_for_difficulty(Student, Course) :-
    course(Course, _ , hard , _),
    % to avoid dublicate hard courses
    once(( 
        student_completed(Student, SomeCourse),
        course(SomeCourse, _ , hard , _)
    )).





%%%%%%% final rule %%%%%%%
recommend(Student, Course) :-
    eligible(Student , Course) , student_interest(Student , Course) , ready_for_difficulty(Student, Course).
