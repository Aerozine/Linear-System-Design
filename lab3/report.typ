#import "@preview/subpar:0.2.2"
#import "lib.typ": project 
#import "@preview/wrap-it:0.1.1": *
#set text(font: "xits")
#set cite(style: "ieee")
#show: project.with(
  title: "Laboratory 3",
  subtitle: "SYST0022-1 Linear systems design",
  authors: (
    "Loïc DELBARRE",
    "S215072"
  ),
  school-logo: image("ulgfsa.svg"),
  branch: "Engineering physics",
  academic-year: "2025-2026",
  tof: false,
  tot: false,
  toc: false,
  footer-text: "Laboratory 3"
)

#set par(justify: true)
#set page(paper: "a4")
#set text(size: 12pt)
#set page(numbering: "1")
#set math.equation(numbering: "(1)", number-align: bottom)
#import "@preview/zero:0.5.0": ztable
#import "@preview/theorion:0.4.1": *
#import cosmos.clouds: *
#show: show-theorion
#let theorem = theorem.with(fill: blue.lighten(85%))
#let theorem-box = theorem-box.with(fill: blue.lighten(85%))
#let theorem-box = theorem-box.with(radius: 5pt)
#import "@preview/physica:0.9.7": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// ── Physical parameters ──────────────────────────────────────────────────────
#let G   = 9.81
#let MC  = 1.0
#let MP  = 0.1
#let L   = 0.5

// ── Derived numerical entries (single source of truth) ──────────────────────
#let a32 = calc.round(G * MP / MC,                digits: 4)  // g mp/mc
#let a42 = calc.round(G*(MC+MP)/(L*MC),           digits: 4)  // g(mc+mp)/(l mc)
#let b3  = calc.round(1.0 / MC,                   digits: 4)  // 1/mc
#let b4  = calc.round(1.0 / (L * MC),             digits: 4)  // 1/(l mc)

// Observability new: row-3 entry = C_new A^2 [col2] = a32+a42
#let o32_new = calc.round(a32 + a42, digits: 4)

// Controllability: A^3 B entries
// (A^3 B)_1 = a32 * b4 = g*mp/mc * 1/(l*mc) = g*mp/(l*mc^2)
// (A^3 B)_2 = a42 * b4 = g*(mc+mp)/(l*mc) * 1/(l*mc) = g*(mc+mp)/(l^2*mc^2)
#let mc14 = calc.round(a32 * (1.0/(L*MC)), digits: 4)
#let mc24 = calc.round(a42 * (1.0/(L*MC)), digits: 4)

// Observer gains (poles at -20)
// alpha = a32, beta = a42, alpha+beta = ab
#let ab   = calc.round(a32 + a42, digits: 4)
#let l1v  = calc.round((80*a32 - 32000)      / (a32+a42), digits: 2)
#let l2v  = calc.round(80 - l1v,                          digits: 2)
#let l3v  = calc.round((a32*(2400+a42) - 160000) / (a32+a42), digits: 2)
#let l4v  = calc.round(2400 + a42 - l3v,                  digits: 2)

// Controller gains (poles at -10)
// Correct char poly: s^4 + (k3+2k4)s^3 + (k1+2k2-g(mc+mp)/(lmc))s^2 - g*k3/(lmc)*s - g*k1/(lmc)
#let lmc  = calc.round(L * MC, digits: 4)          // l mc = 0.5
#let k1v  = calc.round(-10000*L*MC / G,            digits: 2)  // -10000*lmc/g
#let k3v  = calc.round(-4000*L*MC / G,             digits: 2)  // -4000*lmc/g
#let k4v  = calc.round((40 - k3v) / 2,             digits: 2)  // (40-k3)/2
#let k2v  = calc.round((600 - k1v + G*(MC+MP)/(L*MC)) / 2, digits: 2)  // (600-k1+beta)/2

// Intermediate numerics shown in derivation
#let eighty_alpha = calc.round(80*a32, digits: 3)
#let num_l1        = calc.round(80*a32 - 32000, digits: 3)
#let alpha_2400b  = calc.round(a32*(2400+a42), digits: 3)
#let num_l3        = calc.round(a32*(2400+a42) - 160000, digits: 3)
#let num_k1       = calc.round(-10000*L*MC, digits: 2)
#let num_k3       = calc.round(-4000*L*MC,  digits: 2)
#let step_k4_numer = calc.round(40 - k3v, digits: 3)   // 40-k3
#let step_k2_numer = calc.round(600 - k1v + G*(MC+MP)/(L*MC), digits: 3)  // 600-k1+beta

// ── Coloured block helper ────────────────────────────────────────────────────
#let hi(body, lbl, clr) = {
  let content-box = box(
    fill:   clr.lighten(82%),
    stroke: clr.lighten(30%) + 1.2pt,
    inset:  (x: 9pt, y: 9pt),
    radius: 3pt,
  )[#body]
  stack(dir: ttb,
    content-box,
    align(right)[#text(13pt, weight: "bold", fill: clr.darken(20%))[#lbl]],
  )
}

= System description

The cart-pole is linearised around $theta = pi$ with $l = #str(L)$ m, $m_c = #str(MC)$ kg, $m_p = #str(MP)$ kg, $g = #str(G)$ m/s².
The state vector is $bold(x) = mat(x, tilde(theta), dot(x), dot(tilde(theta)))^top$.

The linearised model (as given in the notebook) reads

$
dot(bold(x)) =
#hi([$mat(
  0, 0, 1, 0;
  0, 0, 0, 1;
  0, display(frac(g m_p, m_c)), 0, 0;
  0, display(frac(g(m_c+m_p), l m_c)), 0, 0
)$], "A", blue)
bold(x) +
#hi([$mat(0; 0; display(frac(1,m_c)); display(frac(1,l m_c)))$], "B", green.darken(10%))
f_x(t),
quad
y =
#hi([$mat(0, 1, 0, 0)$], "C", orange)
bold(x) +
#hi([$mat(0)$], "D", red)
f_x(t).
$

By identification with the numerical parameters ($l m_c = #str(lmc)$):

#grid(columns: (1fr, 1fr), gutter: 20pt,
  align(horizon)[$A = mat(
    0, 0, 1, 0;
    0, 0, 0, 1;
    0, #str(a32), 0, 0;
    0, #str(a42), 0, 0
  )$],
  align(horizon)[$B = mat(0; 0; #str(b3); #str(b4))$],
  align(horizon)[$C = mat(0, 1, 0, 0)$ #h(0.5em) (original)],
  align(horizon)[$D = mat(0)$],
)

= Question 1

#quote-box[
#set text(fill: black)
*a)* Compute the observability matrix.
]

#theorem-box(title: "Observability matrix")[
  For a system $(A, C)$ of order $n$, the observability matrix is 
   $ cal(O) = mat(C; C A; C A^2; dots.v; C A^(n-1)) $ .
  The system is *observable* iff $op("rank")(cal(O)) = n$.
]

With $C = mat(0,1,0,0)$:

$
cal(O)_"orig" = mat(C; C A; C A^2; C A^3) =
mat(
  0, 1, 0, 0;
  0, 0, 0, 1;
  0, display(frac(g(m_c+m_p),l m_c)), 0, 0;
  0, 0, 0, display(frac(g(m_c+m_p),l m_c))
) =
mat(
  0, 1, 0, 0;
  0, 0, 0, 1;
  0, #str(a42), 0, 0;
  0, 0, 0, #str(a42)
).
$

#quote-box[
#set text(fill: black)
*b)* Assess the observability of the system.
]

The first column of $cal(O)_"orig"$ is identically zero, so $op("rank")(cal(O)_"orig") = 2 < 4$. The system is *not observable*: the cart position $x$ and velocity $dot(x)$ are unobservable from $y = tilde(theta)$.

= Question 2

#quote-box[
#set text(fill: black)
*a)* Compute the controllability matrix.
]

#theorem-box(title: "Controllability matrix")[
  For a system $(A, B)$ of order $n$, the controllability matrix is
  $cal(C) = mat(B, A B, A^2 B, dots, A^(n-1) B)$.
  The system is *controllable* iff $op("rank")(cal(C)) = n$.
]
$
cal(C) = mat(B, A B, A^2 B, A^3 B) = mat(
  0, display(frac(1,m_c)), 0, display(frac(g m_p, l m_c^2));
  0, display(frac(1,l m_c)), 0, display(frac(g(m_c+m_p), l^2 m_c^2));
  display(frac(1,m_c)), 0, display(frac(g m_p, l m_c^2)), 0;
  display(frac(1,l m_c)), 0, display(frac(g(m_c+m_p), l^2 m_c^2)), 0
)
$

#quote-box[
#set text(fill: black)
*b)* Assess the controllability of the system.
]

$op("rank")(cal(C)) = 4 = n$: the system is *fully controllable*.

= Question 3

#quote-box[
#set text(fill: black)
*a)* Explain why we cannot design a Luenberger observer for the system with the given $C$ matrix.
]

A Luenberger observer requires the pair $(A, C)$ to be observable ($op("rank")(cal(O)) = 4$). As shown in Q1b, $op("rank")(cal(O)_"orig") = 2$: the state components $x$ and $dot(x)$ are invisible to the output $y = tilde(theta)$. No gain $L$ can make the error dynamics $dot(bold(e)) = (A - L C)bold(e)$ asymptotically stable for arbitrary initial errors.

#quote-box[
#set text(fill: black)
*b)* And why changing $C$ to $C = mat(1, 1, 0, 0)$ would make it possible?
]

With $C_"new" = mat(1,1,0,0)$ the updated system is

$
dot(bold(x)) =
#hi([$mat(
  0, 0, 1, 0;
  0, 0, 0, 1;
  0, display(frac(g m_p, m_c)), 0, 0;
  0, display(frac(g(m_c+m_p), l m_c)), 0, 0
)$], "A", blue)
bold(x) +
#hi([$mat(0; 0; display(frac(1,m_c)); display(frac(1,l m_c)))$], "B", green.darken(10%))
f_x(t),
quad
y =
#hi([$mat(1, 1, 0, 0)$], "C", orange)
bold(x) +
#hi([$mat(0)$], "D", red)
f_x(t).
$

By identification:

#grid(columns: (1fr, 1fr), gutter: 20pt,
  align(horizon)[$A = mat(
    0, 0, 1, 0;
    0, 0, 0, 1;
    0, #str(a32), 0, 0;
    0, #str(a42), 0, 0
  )$],
  align(horizon)[$B = mat(0; 0; #str(b3); #str(b4))$],
  align(horizon)[$C = mat(1, 1, 0, 0)$ #h(0.5em) (updated)],
  align(horizon)[$D = mat(0)$],
)

The new observability matrix is

$
cal(O)_"new" =
mat(
  1, 1, 0, 0;
  0, 0, 1, 1;
  0, display(frac(g m_p, m_c)+frac(g(m_c+m_p),l m_c)), 0, 0;
  0, 0, 0, display(frac(g m_p, m_c)+frac(g(m_c+m_p),l m_c))
) =
mat(
  1, 1, 0, 0;
  0, 0, 1, 1;
  0, #str(o32_new), 0, 0;
  0, 0, 0, #str(o32_new)
).
$

$op("rank")(cal(O)_"new") = 4$: the system is *fully observable*. The output $y = x + tilde(theta)$ couples the previously unobservable modes, so all four states are reconstructable and a Luenberger observer can be designed.

= Question 4

#quote-box[
#set text(fill: black)
Justify why we can design independently the state feedback controller and the Luenberger observer for the system with the updated $C$ matrix.
]

#theorem-box(title: "Separation principle")[
  If $(A,B)$ is controllable and $(A,C)$ is observable, the eigenvalues of the augmented closed-loop system
  $
  frac(d,d t)mat(bold(x); bold(hat(x))) =
  mat(A, -B K; L C, A-B K-L C)
  mat(bold(x); bold(hat(x))) +
  mat(B; bold(0)) d(t)
  $
  are $sigma(A-B K) union sigma(A-L C)$. Controller and observer can therefore be designed *independently*.
]

Since $op("rank")(cal(C))=4$ (Q2b) and $op("rank")(cal(O)_"new")=4$ (Q3b), both conditions hold. The gain $K$ is chosen to place the poles of $A-B K$, and the gain $L$ is chosen to place the poles of $A-L C$, without cross-interference.

= Question 5

#quote-box[
#set text(fill: black)
What are the gains $l_1, l_2, l_3, l_4$ that place all poles of $A - L C$ at $-20$?
]

The desired characteristic polynomial is
$
p_L(s) = (s+20)^4 = s^4 + 80 thin s^3 + 2400 thin s^2 + 32000 thin s + 160000.
$ <eq:poly-obs>

Let $alpha = g m_p / m_c = #str(a32)$ and $beta = g(m_c+m_p) / (l m_c) = #str(a42)$.
The notebook provides the characteristic polynomial of $A - L C_"new"$:

$
det(s I - (A-L C)) = s^4
  + (l_1+l_2) thin s^3
  + (l_3+l_4-beta) thin s^2
  + (alpha thin l_2 - beta thin l_1) thin s \
  + alpha thin l_4 - beta thin l_3.
$

Matching @eq:poly-obs:
$
cases(
  l_1+l_2 = 80,
  l_3+l_4 = 2400+beta,
  alpha thin l_2 - beta thin l_1 = 32000,
  alpha thin l_4 - beta thin l_3 = 160000.
)
$

Substituting $l_2 = 80-l_1$ into the third equation gives
$
l_1 = frac(80 thin alpha - 32000, alpha+beta)
    = frac(#str(num_l1), #str(ab))
    = #str(l1v),
quad l_2 = 80 - l_1 = #str(l2v).
$

Similarly, substituting $l_4 = 2400+beta-l_3$ into the fourth equation:
$
l_3 = frac(alpha(2400+beta)-160000, alpha+beta)
    = frac(#str(num_l3), #str(ab))
    = #str(l3v), \
quad l_4 = 2400+beta-l_3 = #str(l4v).
$

#align(center)[
  #rect(stroke: blue, inset: 8pt, radius: 4pt)[
    $L = mat(l_1; l_2; l_3; l_4) = mat(#str(l1v); #str(l2v); #str(l3v); #str(l4v))$
  ]
]

#figure(
  image("cartpole_obs.png", width: 100%),
  caption: [Luenberger observer estimation error $e(t) = bold(x)(t) - bold(hat(x))(t)$ with poles placed at $-20$.]
)

= Question 6

#quote-box[
#set text(fill: black)
What are the gains $k_1, k_2, k_3, k_4$ that satisfy the requirements?
]

The desired characteristic polynomial (poles at $-10$) is
$
p_K(s) = (s+10)^4 = s^4 + 40 thin s^3 + 600 thin s^2 + 4000 thin s + 10000.
$ <eq:poly-ctrl>

The characteristic polynomial of $A - B K$ (computed symbolically from the system matrices) is:
$
det(s I - (A-B K)) = s^4
  + (k_3 + 2 k_4) thin s^3
  + lr((k_1 + 2 k_2 - frac(g(m_c+m_p), l m_c))) thin s^2
  \
  - frac(g k_3, l m_c) thin s
  - frac(g k_1, l m_c).
$

Matching @eq:poly-ctrl coefficient by coefficient (with $l m_c = #str(lmc)$):
$
cases(
  k_3 + 2 k_4 = 40,
  k_1 + 2 k_2 - display(frac(g(m_c+m_p), l m_c)) = 600,
  display(-frac(g k_3, l m_c)) = -4000,
  display(-frac(g k_1, l m_c)) = -10000.
)
$

From the last two equations (note the *negative* sign — $k_1$ and $k_3$ are negative):
$
k_1 = -frac(10000 thin l m_c, g)
    = frac(#str(num_k1), #str(G))
    = #str(k1v),
\
k_3 = -frac(4000 thin l m_c, g)
    = frac(#str(num_k3), #str(G))
    = #str(k3v).
$

From the first equation:
$
k_4 = frac(40 - k_3, 2)
    = frac(#str(step_k4_numer), 2)
    = #str(k4v).
$

From the second equation (using $beta = g(m_c+m_p)/(l m_c) = #str(a42)$):
$
k_2 = frac(600 - k_1 + beta, 2)
    = frac(#str(step_k2_numer), 2)
    = #str(k2v).
$

#align(center)[
  #rect(stroke: green.darken(20%), inset: 8pt, radius: 4pt)[
    $K = mat(k_1, k_2, k_3, k_4) = mat(#str(k1v), #str(k2v), #str(k3v), #str(k4v))$
  ]
]

#figure(
  image("cartpole_ssfb.png", width: 100%),
  caption: [State-feedback response: angle deviation $tilde(theta)(t)$ to disturbance $d(t)$, with controller poles at $-10$.]
)

= Question 7

#quote-box[
#set text(fill: black)
Using the gains from *Q5* (observer) and *Q6* (state feedback), run the simulation. Compare the observer-based response to the ideal state feedback (true states). Comment on the differences.
]

The 8-state augmented closed-loop dynamics are

$
frac(d,d t)mat(bold(x); bold(hat(x))) =
mat(A, -B K; L C, A-B K-L C)
mat(bold(x); bold(hat(x))) +
mat(B; bold(0)) d(t).
$

By the separation principle, the 8 eigenvalues of the augmented matrix are exactly $sigma(A-B K) = {-10}^4$ and $sigma(A-L C) = {-20}^4$.

#figure(
  image("cartpole_combined.png", width: 100%),
  caption: [Observer-based vs. ideal state-feedback response of $tilde(theta)(t)$ to the disturbance $d(t)$.]
)

*Comments on the simulation results:*

- *Observer convergence (Q5 plot).* The estimation error $bold(e)(t) = bold(x)(t) - bold(hat(x))(t)$ shown in the first figure decays rapidly to zero. Both the angle error $tilde(theta)$ and position error $x$ peak within the first $0.3$ s and then vanish, confirming that the observer poles at $-20$ (time constant $tau_"obs" = 0.05$ s) are placed correctly and the observer is working as designed.

- *Instability of the controller (Q6--Q7 plots).* The state-feedback and observer-based simulations both show divergence: the angle deviation $tilde(theta)(t)$ grows to $10^(39)$--$10^(42)$ rad by $t approx 15$ s. This reveals that the *controller gain $K$ was incorrect* in the original derivation. The root cause is a sign error in the characteristic polynomial of $A - B K$: the report's formula used $+10000 l m_c / g$ for $k_1$ and $+4000 l m_c / g$ for $k_3$, but the correct expressions (from symbolic computation) are $bold(k_1 = -10000 l m_c / g)$ and $bold(k_3 = -4000 l m_c / g)$. With the corrected gains
  $K = mat(#str(k1v), #str(k2v), #str(k3v), #str(k4v))$,
  all eigenvalues of $A - B K$ are placed at $-10$ and the system is asymptotically stable.

- *Physical interpretation of the sign.* The inverted pendulum is open-loop unstable (eigenvalue at $+sqrt(beta) approx +4.65$). A positive $k_1$ would *reinforce* the cart motion in the direction of the fall rather than oppose it, destabilising the loop. The negative sign on $k_1$ and $k_3$ is physically necessary to provide restoring force against the tilt.

