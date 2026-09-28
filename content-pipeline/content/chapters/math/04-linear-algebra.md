---
topic: math
position: 4
title: Linear algebra: vectors and matrices
summary: Vectors, matrix multiplication, determinants, solving systems of equations and a first look at eigenvalues.
difficulty: 3
sources:
- Wikipedia: Matrix (mathematics) | https://en.wikipedia.org/wiki/Matrix_(mathematics)
- Wikipedia: Determinant | https://en.wikipedia.org/wiki/Determinant
- Wikipedia: Eigenvalues and eigenvectors | https://en.wikipedia.org/wiki/Eigenvalues_and_eigenvectors
---
## Why linear algebra?

Linear algebra handles many quantities at once. It solves circuits with dozens of nodes, rotates 3D graphics, runs control systems and powers machine learning, where neural networks are mostly giant matrix multiplications.

## Vectors

A **vector** has both size and direction, such as a force, a velocity or an electric field. It is written as a list of components: v = (3, 4). Its **magnitude** is found with Pythagoras: |v| = √(3² + 4²) = 5.

The **dot product** of a = (a₁, a₂) and b = (b₁, b₂) is a₁b₁ + a₂b₂. It also equals |a| × |b| × cos θ, so it measures how aligned two vectors are: zero means they are perpendicular. In physics, work is the dot product of force and displacement.

## Matrices

A **matrix** is a rectangular grid of numbers. A 2 × 3 matrix has 2 rows and 3 columns. Matrices of the same size add element by element.

**Matrix multiplication** combines rows of the first with columns of the second: each entry of the result is the dot product of a row and a column.

> [1 2]   [5 6]   [1·5+2·7  1·6+2·8]   [19 22]
> [3 4] × [7 8] = [3·5+4·7  3·6+4·8] = [43 50]

Two important facts:

- The inner dimensions must match: (m × n) times (n × p) gives (m × p).
- Order matters: in general AB ≠ BA.

The **identity matrix** I (ones on the diagonal, zeros elsewhere) behaves like the number 1: AI = A.

## Systems of equations as matrices

A system of linear equations can be written Ax = b. For example:

> 2x + y = 5
> x − y = 1

becomes A = [[2, 1], [1, −1]], x = (x, y), b = (5, 1). Solving it means finding x. The systematic method is **Gaussian elimination**: combine rows to create zeros below the diagonal, then back-substitute. Here, adding the equations gives 3x = 6, so x = 2 and y = 1.

This is exactly how circuit simulators work. Nodal analysis writes KCL at every node, producing a matrix equation G·v = i (conductances times node voltages equals currents), which the software solves for all voltages at once.

## The determinant

For a 2 × 2 matrix [[a, b], [c, d]]:

> det = ad − bc

The determinant tells you whether a matrix can be inverted. If det = 0 the matrix is **singular**: the equations are either contradictory or dependent, and there is no unique solution. If det ≠ 0, the inverse exists and x = A⁻¹b. For a 2 × 2 matrix the inverse is (1/det) × [[d, −b], [−c, a]].

Geometrically, the determinant is the factor by which the matrix scales areas. A determinant of 0 squashes the plane onto a line.

## Matrices as transformations

A matrix transforms vectors. The matrix [[cos θ, −sin θ], [sin θ, cos θ]] rotates any vector by the angle θ. Scaling, shearing and reflecting are all matrices, and applying several transformations in a row means multiplying their matrices. Game engines and robot arms do this constantly.

![The rotation matrix R turns every vector 90° anticlockwise: (3, 1) becomes (−1, 3).](matrix_rotation)

## Eigenvalues and eigenvectors

For most vectors, multiplying by a matrix changes their direction. But some special vectors only get stretched:

> A·v = λ·v

v is an **eigenvector** and λ (lambda) is its **eigenvalue**, the stretch factor. They are found by solving det(A − λI) = 0.

Eigenvalues are everywhere in engineering. In control systems and circuits, the eigenvalues of the system matrix decide **stability**: if all of them have negative real parts, disturbances die away; if any has a positive real part, the system runs away. They also give the natural frequencies of vibrating structures, and Google's original PageRank algorithm is an eigenvector problem.

# Key points
- A vector has magnitude and direction; |(3, 4)| = 5; a zero dot product means perpendicular.
- Matrix multiplication: rows times columns; inner dimensions must match; AB ≠ BA in general.
- Linear systems are Ax = b; Gaussian elimination solves them, as circuit simulators do.
- For a 2 × 2 matrix, det = ad − bc; det = 0 means no inverse and no unique solution.
- Eigenvectors satisfy Av = λv; eigenvalues decide stability and natural frequencies.

# Quiz
Q: What is the magnitude of the vector (6, 8)?
- 14
* 10
- 48
- 7
> √(6² + 8²) = √(36 + 64) = √100 = 10.

Q: What is the determinant of [[4, 2], [3, 5]]?
- 26
* 14
- 20
- 2
> ad − bc = 4 × 5 − 2 × 3 = 20 − 6 = 14.

Q: A matrix has a determinant of zero. What does that mean for Ax = b?
- It has exactly one solution
* The matrix has no inverse, so there is no unique solution
- The solution is x = 0
- The matrix is the identity
> A singular matrix squashes space into fewer dimensions, so it cannot be undone and the system has no unique solution.

Q: A 3 × 2 matrix is multiplied by a 2 × 4 matrix. What is the size of the result?
- 2 × 2
* 3 × 4
- 4 × 3
- The product is not defined
> Inner dimensions (2 and 2) match; the result takes the outer dimensions, 3 × 4.

Q: What do the eigenvalues of a system matrix tell a control engineer?
- The cost of the system
* Whether the system is stable
- The number of inputs
- The voltage of the supply
> If every eigenvalue has a negative real part, disturbances decay and the system is stable.
