(defun grad-check (person degree-requirements catalog)
  ; return t if has enough total credits and has all required courses
  ; return a list of problems otherwise
  (let ((missing-courses '())
		(hour-requirement (cadar degree-requirements)) ; 64
		(course-requirements (cdadr degree-requirements)) ; (COS382 COS121 (OR MAT215 COS284))
		; (electives (cdaddr degree-requirements)); (COS104 COS109)
		(hour-fulfilled 0)
		(transcript (cdar person))
		(plan (cdadr person)) )
	; first check if the hours are fulfilled
;	(format t "Checking if hours are fulfilled...~%")
	(dolist (course transcript) (setf hour-fulfilled (+ hour-fulfilled (get-credit-hours course catalog))))
	(dolist (course plan) (setf hour-fulfilled (+ hour-fulfilled (get-credit-hours course catalog))))
	; then check if the required courses are all taken
;	(format t "Checking if required courses are fulfilled...~%")
	(dolist (course-requirement course-requirements) 
	  (if (not (requirement-fulfilled course-requirement person))
		(push course-requirement missing-courses) ))
	(let ((requirements-fulfilled (and (null missing-courses) (>= hour-fulfilled hour-requirement)))
		  (missing-hours (if (>= hour-fulfilled hour-requirement) 0 (- hour-requirement hour-fulfilled)))
		  )
	  (values requirements-fulfilled missing-courses missing-hours) )
	)
  )

(defun requirement-fulfilled (course-requirement person)
  ; course-requirement can be either a name: 'COS280, or a compound statement: '(or COS280 COS380)
  (cond
	((not (listp course-requirement))
	 ; if not a list, then assume course-requirement is a course name
	 (requirement-fulfilled-with-course-name course-requirement person) )
	((string= (car course-requirement) "OR")
	 ; if is a 'or' form, evaluate with the 'or' function
	 (requirement-fulfilled-with-or (cdr course-requirement) #'requirement-fulfilled person) )
	(t
	  ; if is an unrecognized form, evaluate with the generic evaluation function
;	  (format t "UNRECOGNIZED OPERATOR: evaluating ~A with ~A~%" (cdr course-requirement) (car course-requirement))
	  (eval (cons (car course-requirement) (requirement-fulfilled-with-form (cdr course-requirement) #'requirement-fulfilled person))) ) ))

(defun requirement-fulfilled-with-course-name (course-name person)
  ; return t if fulfilled, nil if not fulfilled
  (let ((transcript (cdar person))
		(plan (cdadr person)) )
	(and (or
		   (find-if (lambda (course) (and
									   (string= (car course) course-name)
									   (grade-ok course)))
					transcript )
		   (member course-name plan) )
		 t )))

(defun requirement-fulfilled-with-or (lst func person)
  ; return t if fulfilled, nil if not fulfilled
  (if (null (cdr lst)) ; if this is the last element
	(funcall func (car lst) person)
	(let ((result (or (funcall func (car lst) person) (requirement-fulfilled-with-or (cdr lst) func person)) ))
;	  (format t "OR: ~A proved to ~A~%" lst result)
	  result )))

(defun requirement-fulfilled-with-form (lst func person)
  ; return a list of fulfillment result, based on items in lst
  (if (null (cdr lst)) ; if this is the last element
	(list (funcall func (car lst) person))
	(let ((result (cons (funcall func (car lst) person) (requirement-fulfilled-with-form (cdr lst) func person))))
;	  (format t "FORM: ~A proved to ~A~%" lst result)
	  result )))

(defun grade-ok (course)
  ; course must be of the form (COS### A-)
  (let ((grade-letter (subseq (string (cadr course)) 0 1)))
	(or (string= grade-letter "A")
		(string= grade-letter "B")
		(string= grade-letter "C") )))

(defun get-credit-hours (course catalog)
  ; course can be either a course name or a list of course and grade
  ; return number of credits on good grade and valid course, otherwise 0
  (if (listp course)
	; if course is a list
	(if (grade-ok course)
	  ; and grade is good, return the search result for (car course)
	  (get-credit-hours-with-course-name (car course) catalog)
	  ; and bad grade, then return nil
	  0 )
	; if not a list
	(get-credit-hours-with-course-name course catalog)) )

(defun get-credit-hours-with-course-name (course-name catalog)
  ; course-name can only be a string
  ; return number of credits on valid course, otherwise 0
  (or 
	(cadr (find-if (lambda (catalog-item) (string= (car catalog-item) course-name)) catalog))
	0 ))


(defparameter person '(
  (transcript (COS102 A-) (COS109 A) (COS120 B) (COS121 B+) (COS143 A-) (COS243 B+) (COS265 B) (COS284 B-) (MAT151 A-) (MAT210 B) (COS104 D-))
  (plan COS492 COS493 COS280 COS331 COS340 COS350 SYS214 SYS411 MAT215 COS104 COS311 COS450 COS382) ))

(defparameter catalog '( (COS102 3) (COS104 2) (COS109 3) (COS120 4) (COS121 4) (COS130 3) (COS143 3) (COS170 3)
 (COS232 3) (COS243 3) (COS265 3) (COS270 3) (COS280 3) (COS284 3)
 (COS310 1) (COS311 3) (COS321 3) (COS320 3) (COS323 3) (COS333 3) (COS340 3) (COS343 3)
 (COS350 3) (COS351 3) (COS355 3) (COS360 3) (COS370 3) (COS380 3) (COS381 3) (COS382 3) (COS393 3) (COS394 3)
 (COS411 3) (COS421 3) (COS424 3) (COS425 3) (COS432 3) (COS433 3) (COS435 3) (COS436 3)
 (COS450 3) (COS492 3) (COS493 1)
 (MAT151 4) (MAT215 3) (MAT210 4) (MAT230 4) (MAT240 4) (MAT245 4) (MAT251 4) (MAT352 4)
 (SYS214 3) (SYS352 3) (SYS401 3) (SYS402 3) (SYS403 3) (SYS411 3) ))
(defparameter degree-requirements 
  '((major-hours 64)
   (required COS102 COS120 COS121 COS143 COS243 COS265 COS284 COS492 COS493 MAT151 MAT215
			 (OR COS311 COS321)
			 (OR COS320 COS382 COS435)
			 (OR COS393 COS394 COS450)
			 (OR MAT210 MAT352) )
   (electives COS104 COS109 COS130 COS170 
			  COS232 COS270 COS280 
			  COS310 COS323 COS331 COS333 COS340 COS343 COS350 
			  COS351 COS355 COS360 COS370 COS380 COS381
			  COS411 COS421 COS424 COS425 COS432 COS433 COS436
			  MAT230 MAT240 MAT245 MAT251
			  SYS214 SYS352 SYS401 SYS402 SYS403 SYS411) ))

;(print (grad-check person degree-requirements catalog))
(multiple-value-bind (fir sec thd) (grad-check person degree-requirements catalog)
  (format t "Fulfilled: ~A~%Missing courses: ~A~%Missing hours: ~A~%" fir sec thd) )
