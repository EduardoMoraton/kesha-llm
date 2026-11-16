#!/usr/bin/env python3
"""Draws the Kesha lovebird (agapornis) icon -> icon.png (256x256). Run with any pygame: python3 make_icon.py"""
import os
os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
import pygame

S = 1024  # draw big, scale down for smooth edges
s = pygame.Surface((S, S), pygame.SRCALPHA)
d = pygame.draw



def curve(*pts, steps=12):
    """Smooth closed outline through the given points (Catmull-Rom), for round organic shapes."""
    out, n = [], len(pts)
    for i in range(n):
        p0, p1, p2, p3 = pts[i - 1], pts[i], pts[(i + 1) % n], pts[(i + 2) % n]
        for k in range(steps):
            u = k / steps
            out.append(tuple(0.5 * (2 * b + (c - a) * u + (2 * a - 5 * b + 4 * c - e) * u * u + (3 * b - a - 3 * c + e) * u ** 3)
                             for a, b, c, e in zip(p0, p1, p2, p3)))
    return out


GREEN, DARK, LIGHT = (72, 190, 84), (36, 138, 66), (150, 222, 110)
YELLOW, ORANGE, RED = (255, 205, 60), (250, 120, 50), (225, 50, 50)

d.rect(s, (24, 32, 52), (0, 0, S, S), border_radius=220)                 # background tile
d.circle(s, (38, 52, 84), (512, 500), 400)                               # soft halo
d.polygon(s, DARK, [(360, 760), (300, 930), (400, 900), (470, 780)])     # short tail
d.polygon(s, (60, 120, 220), [(370, 790), (335, 900), (400, 880)])       # blue rump feathers
d.ellipse(s, GREEN, (300, 420, 430, 470))                                # chubby body
d.ellipse(s, LIGHT, (450, 560, 250, 300))                                # belly
d.ellipse(s, YELLOW, (400, 400, 340, 250))                               # yellow collar / chest
d.ellipse(s, DARK, (300, 510, 240, 330))                                 # wing
d.ellipse(s, (25, 110, 55), (330, 600, 170, 220))
d.circle(s, ORANGE, (580, 350), 215)                                     # orange head
d.ellipse(s, (242, 88, 44), (490, 140, 250, 190))                                 # redder forehead
d.circle(s, ORANGE, (560, 380), 180)
d.polygon(s, (175, 35, 40), curve((750, 400), (800, 395), (850, 430), (840, 500), (790, 505), (750, 470)))  # lower beak
d.polygon(s, RED, curve((735, 265), (830, 240), (915, 300), (925, 400), (900, 480), (862, 525),       # upper beak,
                        (868, 455), (840, 420), (790, 412), (740, 425)))                             # hooked tip
d.polygon(s, (255, 120, 110), curve((770, 285), (830, 275), (880, 320), (840, 315), (790, 320)))     # highlight
d.circle(s, (150, 25, 30), (775, 345), 9)                                                            # nostril
d.circle(s, (255, 255, 255), (640, 310), 68)                             # white eye ring
d.circle(s, (20, 24, 36), (648, 310), 40)
d.circle(s, (255, 255, 255), (664, 296), 12)
for x in (470, 580):                                                     # feet
    d.rect(s, (200, 170, 170), (x, 860, 26, 60), border_radius=10)
d.rect(s, (120, 84, 60), (300, 905, 440, 34), border_radius=17)          # perch

pygame.image.save(pygame.transform.smoothscale(s, (256, 256)), os.path.join(os.path.dirname(__file__) or ".", "icon.png"))
