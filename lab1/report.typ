#import "@preview/subpar:0.2.2"
#import "lib.typ": project
#import "@preview/dashy-todo:0.1.3": todo
#import "@preview/wrap-it:0.1.1": *
#set text(font: "xits")
#set cite(style: "ieee")
#show: project.with(
  title: "Laboratory 1",
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
  footer-text: "Laboratory 1"
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

= Question 1

#quote-box[
#set text(fill: black)
Let $P(s)$ denote the plant transfer function. Draw the block diagram of a closed-loop system controlled with a PID controller.
The controller block should be detailed into its proportional, integral, and derivative actions in frequency domain form.
]
The block diagram of a closed-loop system controlled with a PID controller can be seen as :

#diagram(
  node-stroke: 0.8pt,
  edge-stroke: 0.8pt,
  node-corner-radius: 2pt,
  spacing: (14mm, 10mm),
  node((0,0), $r(s)$, stroke: none, name: <r>),
  node((1,0), $+$, shape: circle, width: 7mm, name: <sum>),
  node((2.5,0),
    align(center)[
      $C(s)$ 
      #v(-6pt)
      $= k_P + display(k_I/s) + display(k_D s)$
    ],
    width: 38mm, height: 16mm,
    name: <pid>
  ),
  node((4.5,0),
    $P(s)$,
    width: 18mm, height: 10mm,
    name: <plant>
  ),
  node((5.5, 0), stroke: none, name: <tap>),
  node((6.5, 0), $y(s)$, stroke: none, name: <y>),
  node((5.5, 1.1), stroke: none, name: <fb1>),
  node((1,   1.1), stroke: none, name: <fb2>),
  node((3.5, 1.1),
    $-1$,
    width: 12mm, height: 9mm,
    name: <neg>
  ),
  edge(<r>, <sum>, "-|>"),
  edge(<sum>, <pid>, "-|>", label: $e(s)$, label-pos: 0.40),
  edge(<pid>, <plant>, "-|>", label: $u(s)$, label-pos: 0.45),
  edge(<plant>, <tap>, "-"),
  edge(<tap>, <y>, "-|>"),
  edge(<tap>, <fb1>, "-"),
  edge(<fb1>, <neg>, "-|>"),
  edge(<neg>, <fb2>, "-"),
  edge(<fb2>, <sum>, "-|>"),
)
Where 
- r(s)
- e(s)
- u(s)
- P(s)
- C(s)
- y(s)

= Question 2
#quote-box[
#set text(fill: black)
Let $r$ and $y$ denote the reference and the output of the controlled system. Based on the block diagram you drew at the previous point, give the expression of the closed-loop transfer function $G_(y r)(s)$.
] 
= Question 3
#quote-box[
#set text(fill: black)
Intuitively, what would be the effect of modifying each parameter ($k_P$, $k_I$, and $k_D$) independently?
]
= Question 4
#quote-box[
#set text(fill: black)
In the following simulation, tune the proportional and integral gains $k_P$ and $k_I$.

a)  Give a set of values for which the actual angle converges towards the reference angle. In the case you can't find any, what's the apparent problem with the PI controller?

 b) Does the integral action improve the behavior of the control system? Why?
 ]
= Question 5
#quote-box[
#set text(fill: black)
We will now add a derivative action to the system. Tune the parameters of the PID controller. Give a good set of parameters ($k_P$, $k_I$, and $k_D$) for which the actual distance converges quickly towards the reference angle.
 Explain why the derivative action improves the behavior of the controlled system.
 ]
= Question 6
#quote-box[
#set text(fill: black)
We will keep the same set of parameters you found at the previous point and add some disturbance on the control (the force $f_x$ applied) and measurement noise on the output of the angle sensor.
 Is your design still valid when noise is added? Explain why focusing on your controller components.
]


