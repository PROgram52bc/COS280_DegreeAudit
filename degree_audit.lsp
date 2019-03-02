
(defun get-credit-hours (course catalog)
  ; course can be either a course name or a list of course and grade
  ; return number of credits on good grade and valid course, otherwise nil
  (cond
	((listp course) (let ((grade-letter (subseq (string (cadr course)) 0 1)))
					 (if (or (string= grade-letter "A")
							 (string= grade-letter "B")
							 (string= grade-letter "C") )
					   ; if course is a list, and grade is good, return the search result for (car course)
					   (get-credit-hours-with-course-name (car course) catalog)
					   ; if course is a list, and bad grade, then return nil
					   nil )))
	(t (get-credit-hours-with-course-name course catalog)) ))

(defun get-credit-hours-with-course-name (course-name catalog)
  ; course-name can only be a string
  ; return number of credits on valid course, otherwise nil
  (cadr (find-if (lambda (catalog-item) (string= (car catalog-item) course-name)) catalog))
  )


(defparameter person '( 
  (transcript (COS102 A-) (COS109 A) (COS120 B) (COS121 B+) (COS143 A-) (COS243 B+) (COS265 B) (COS284 B-) (MAT151 A-) (MAT210 B))
  (plan COS492 COS493 COS280 COS331 COS340 COS350 SYS214 SYS411 MAT215) ))

(defparameter catalog '( (COS102 3) (COS104 2) (COS109 3) (COS120 4) (COS121 4) (COS130 3) (COS143 3) (COS170 3)
 (COS232 3) (COS243 3) (COS265 3) (COS270 3) (COS280 3) (COS284 3) 
 (COS310 1) (COS311 3) (COS321 3) (COS320 3) (COS323 3) (COS333 3) (COS340 3) (COS343 3) 
 (COS350 3) (COS351 3) (COS355 3) (COS360 3) (COS370 3) (COS380 3) (COS381 3) (COS382 3) (COS393 3) (COS394 3) 
 (COS411 3) (COS421 3) (COS424 3) (COS425 3) (COS432 3) (COS433 3) (COS435 3) (COS436 3)
 (COS450 3) (COS492 3) (COS493 1)
 (MAT151 4) (MAT215 3) (MAT210 4) (MAT230 4) (MAT240 4) (MAT245 4) (MAT251 4) (MAT352 4)
 (SYS214 3) (SYS352 3) (SYS401 3) (SYS402 3) (SYS403 3) (SYS411 3) ))

(print catalog)


;(defun is-fulfilled (course-name person)
;
;  )
;
;(defun is-fulfilled-transcript (course-name transcript)
;
;
;  )
;
;(defun is-fulfilled-plan (course-name plan)
;
;  )
