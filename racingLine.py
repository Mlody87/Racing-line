import pygame
import pygame.gfxdraw
import math
import numpy as np
import copy

SCREEN_WIDTH=1344
SCREEN_HEIGHT=1000


startPoints = [[873, 664],[1071, 683],[1213, 562],[1221, 417],[1201, 196],[1073, 92],[1003, 227],[924, 351],[785, 291],[663, 341],[538, 258],[422, 163],[258, 86],[166, 223],[263, 488],[253, 714],[268, 857],[391, 864],[517, 763],[712, 796]]
nodes = [(81,196),(108,210),(152,216),(182,185),(190,159),(198,122),(226,9),(224,41),(204,15),(158,24),(146,52),(157,93),(124,129),(83,104),(77,62),(40,57),(21,83),(33,145),(30,198),(48,21)]
borderA = []
borderB = []
track = []
racingLine = []
displacement = []
#displacement[20] - iNodes?
totalSplineLength = 0.0
trackWidth=30
iNodes = 20
iterations = 1
tick = 100
timeCount=0
fMarker=1
fOffset = 0

class nod:
    def __init__(self):
        self.x = 0
        self.y = 0
        self.length = 0

class Car:
    def __init__(self, position):
        pygame.sprite.Sprite.__init__(self)
        loaded_image = pygame.image.load('car.png')
        self.position = nod()
        self.position.x=position.x
        self.position.y=position.y
        self.speed = 2
        self.maxSpeed = 8
        self.startAngle = -90
        self.src_image = pygame.transform.rotate(loaded_image, int(self.startAngle))

    def update(self):
        fOffset = getNormalisedOffset(fMarker, racingLine)
        car_p = getSplinePoint(fOffset, racingLine)
        car_g = getSplineGradient(fOffset, racingLine)

        self.position.x = car_p[0]
        self.position.y = car_p[1]

        self.wiodacy = (self.position.x+car_g[0], self.position.y+car_g[1])
        directionP = (self.position.x+car_g[0], self.position.y+car_g[1])

        rel_x, rel_y = directionP[0] - self.position.x, directionP[1] - self.position.y
        angle = (180 / math.pi) * -math.atan2(rel_y, rel_x)

        self.image = pygame.transform.rotate(self.src_image, int(angle))
        self.rect = self.image.get_rect()
        self.rect.center = (self.position.x, self.position.y)
        if(auto):
            screen.blit(self.image, self.rect)

        #print(self.rect.center)


def getNormalisedOffset(p ,points):
	#Which node is the base?
	i = 0
	while (p > points[i].length):
		p -= points[i].length
		i+=1

	#The fractional is the offset
	return i + (p / points[i].length)


def getSplinePoint(t, points):

    p1 = int(t) % len(points)
    p2 = (p1 + 1) % len(points)
    p3 = (p2 + 1) % len(points)
    if(p1 >= 1):
        p0 = p1-1
    else:
        p0 = len(points) - 1

    t= t - int(t)

    tt = t * t
    ttt = tt * t

    q1 = -ttt + 2.0 * tt - t
    q2 = 3.0 * ttt - 5.0 * tt + 2.0
    q3 = -3.0 * ttt + 4.0 * tt + t
    q4 = ttt - tt

    tx = 0.5 * (points[p0].x * q1 + points[p1].x * q2 + points[p2].x * q3 + points[p3].x * q4)
    ty = 0.5 * (points[p0].y * q1 + points[p1].y * q2 + points[p2].y * q3 + points[p3].y * q4)

    return (tx,ty)

def getSplineGradient(t, points):
    p1 = int(t) % len(points)
    p2 = (p1 + 1) % len(points)
    p3 = (p2 + 1) % len(points)
    if(p1 >= 1):
        p0 = p1-1
    else:
        p0 = len(points) - 1

    t= t - int(t)

    tt = t * t
    ttt = tt * t

    q1 = -3.0 * tt + 4.0 * t - 1.0
    q2 = 9.0 * tt - 10.0 * t
    q3 = -9.0 * tt + 8.0 * t + 1.0
    q4 = 3.0 * tt - 2.0 * t

    tx = 0.5 * (points[p0].x * q1 + points[p1].x * q2 + points[p2].x * q3 + points[p3].x * q4)
    ty = 0.5 * (points[p0].y * q1 + points[p1].y * q2 + points[p2].y * q3 + points[p3].y * q4)

    return [tx,ty]

def calculateSegmentLength(p, points):
    fLength = 0.0
    fStepSize = 0.1

    old_point = getSplinePoint(p, points)
    #print("Dla i: ",p)
    t=0
    while t<1.0:
        new_point = getSplinePoint(p + t, points)
        qwe = math.sqrt((new_point[0] - old_point[0])*(new_point[0] - old_point[0]) + (new_point[1] - old_point[1])*(new_point[1] - old_point[1]))
        fLength += math.sqrt((new_point[0] - old_point[0])*(new_point[0] - old_point[0]) + (new_point[1] - old_point[1])*(new_point[1] - old_point[1]))
        old_point = new_point
        t+=fStepSize
    #print("Dlugosc: ",fLength)

    return fLength

def updateSplineProperties(points):
    total = 0.0
    for i in range(0, len(points)):
        points[i].length = calculateSegmentLength(i, points)
        total += points[i].length
        #print("dla: ",i)
    return total

def calcRacingLine():
    # Reset racing line
    for i in range(0, len(racingLine)):
        racingLine[i] = copy.deepcopy(track[i])
        displacement[i] = 0

    totalSplineLength = updateSplineProperties(racingLine)

    for i in range(0, iterations):
        for i in range(0, len(racingLine)):
            #Get locations of neighbour nodes
            pointRight = racingLine[(i + 1) % len(racingLine)]
            pointLeft = racingLine[(i + len(racingLine) - 1) % len(racingLine)]
            pointMiddle = racingLine[i]

            #Create vectors to neighbours
            vectorLeft = [pointLeft.x - pointMiddle.x, pointLeft.y - pointMiddle.y]
            vectorRight = [pointRight.x - pointMiddle.x, pointRight.y - pointMiddle.y]

            #Normalise neighbours
            lengthLeft = math.sqrt(vectorLeft[0] * vectorLeft[0] + vectorLeft[1] * vectorLeft[1])
            leftn = [vectorLeft[0] / lengthLeft, vectorLeft[1] / lengthLeft]
            lengthRight = math.sqrt(vectorRight[0] * vectorRight[0] + vectorRight[1] * vectorRight[1])
            rightn = [vectorRight[0] / lengthRight, vectorRight[1] / lengthRight]

            #Add together to create bisector vector
            vectorSum = [rightn[0] + leftn[0], rightn[1] + leftn[1]]
            lengt = math.sqrt(vectorSum[0] * vectorSum[0] + vectorSum[1] * vectorSum[1])
            vectorSum[0] /= lengt
            vectorSum[1] /= lengt

            #Get point gradient and normalise
            g = getSplineGradient(i, track)
            glen = math.sqrt(g[0] * g[0] + g[1] * g[1])
            g[0] /= glen
            g[1] /= glen

            #Project required correction onto point tangent to give displacment
            dp = -g[1] * vectorSum[0] + g[0] * vectorSum[1]

            #Shortest path
            #displacement[i] += dp * 0.3

            #Curvature
            displacement[(i + 1) % len(racingLine)] += dp * -0.2
            displacement[(i - 1 + len(racingLine)) % len(racingLine)] += dp * -0.2


        #Clamp displaced points to track width
        for i in range(0, len(racingLine)):
            if (displacement[i] >= trackWidth):
                displacement[i] = trackWidth
            if (displacement[i] <= -trackWidth):
                displacement[i] = -trackWidth

            g = getSplineGradient(i, track)
            glen = math.sqrt(g[0] * g[0] + g[1] * g[1])
            g[0] /= glen
            g[1] /= glen

            racingLine[i].x = track[i].x + -g[1] * displacement[i]
            racingLine[i].y = track[i].y + g[0] * displacement[i]


pygame.init()
czerwony = (255,0,0,255)
bialy = (255,255,255,255)
zielony = (58, 156, 53, 255)
niebieski = (91, 99, 210, 255)
szary = (235,235,235, 255)

screen = pygame.display.set_mode([SCREEN_WIDTH,SCREEN_HEIGHT])
clock = pygame.time.Clock()
screen.fill([255,255,255])
trackBg = pygame.image.load("track4.bmp")

pygame.font.init()
myfont = pygame.font.SysFont('Comic Sans MS', 30)
smallfont = pygame.font.SysFont('Comic Sans MS', 15)

wiodacy = False
srodekDrogi = False
drogaAuta = False
punktyDrogi = False
auto = False


for i in range(0, iNodes):
    if(len(startPoints)>0):
        track.append(nod())
        track[i].x = startPoints[i][0]
        track[i].y = startPoints[i][1]
    else:
        x = 100 * math.sin(i / iNodes * 3.14159 * 2) + SCREEN_WIDTH / 2
        y = 100 * math.cos(i / iNodes * 3.14159 * 2) + SCREEN_HEIGHT / 2
        track.append(nod())
        track[i].x=x
        track[i].y=y
    if(i==2):
        car=Car(track[i])

    borderA.append(nod())
    borderB.append(nod())
    racingLine.append(nod())
    displacement.append(0)

gameExit = False
mouse=False
nodeClicked=-1
while not gameExit:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            gameExit = True
        if event.type == pygame.MOUSEBUTTONDOWN:
            mp = pygame.mouse.get_pos()
            mouse=True
            for i, node in enumerate(track):
                d = math.sqrt(math.pow(node.x - mp[0], 2) + math.pow(node.y - mp[1], 2));
                if(d<20):
                    nodeClicked=i
                    break
        if event.type == pygame.MOUSEBUTTONUP:
            mouse=False
            nodeClicked=-1

        if event.type == pygame.KEYDOWN and event.key == pygame.K_q:
            if(wiodacy):
                wiodacy=False
            else:
                wiodacy=True
        if event.type == pygame.KEYDOWN and event.key == pygame.K_w:
            if(srodekDrogi):
                srodekDrogi=False
            else:
                srodekDrogi=True
        if event.type == pygame.KEYDOWN and event.key == pygame.K_e:
            if(drogaAuta):
                drogaAuta=False
            else:
                drogaAuta=True
        if event.type == pygame.KEYDOWN and event.key == pygame.K_r:
            if(punktyDrogi):
                punktyDrogi=False
            else:
                punktyDrogi=True
        if event.type == pygame.KEYDOWN and event.key == pygame.K_t:
            if(auto):
                auto=False
            else:
                auto=True
        if event.type == pygame.KEYDOWN and event.key == pygame.K_p:
            print("Punkty:")
            for i in track:
                print([i.x, i.y])
        if event.type == pygame.KEYDOWN and event.key == pygame.K_a:
            iterations += 1
            #calcRacingLine()
        if event.type == pygame.KEYDOWN and event.key == pygame.K_s:
            iterations -= 1
            #calcRacingLine()
        if (iterations < 0):
            iterations = 0


    if(mouse):
        if(nodeClicked>=0):
            pos = pygame.mouse.get_pos()
            track[nodeClicked].x = pos[0]
            track[nodeClicked].y = pos[1]
            #calcRacingLine()


    screen.blit(trackBg, [0, 0])

    #Move car around racing line
    fMarker += 2.0 * timeCount
    if (fMarker >= totalSplineLength):
        fMarker -= totalSplineLength

    for i in range(0, len(track)):
        p1 = getSplinePoint(i, track)
        g1 = getSplineGradient(i, track)
        glen = math.sqrt(g1[0] * g1[0] + g1[1] * g1[1])

        borderA[i].x = p1[0] + trackWidth * (-g1[1] / glen)
        borderA[i].y = p1[1] + trackWidth * (g1[0] / glen)
        borderB[i].x = p1[0] - trackWidth * (-g1[1] / glen)
        borderB[i].y = p1[1] - trackWidth * (g1[0] / glen)

    res = 0.1
    t = 0.0
    while t < len(track):
        pl1 = getSplinePoint(t, borderA);
        pr1 = getSplinePoint(t, borderB);
        pl2 = getSplinePoint(t + res, borderA);
        pr2 = getSplinePoint(t + res, borderB);
        listA = [(pl1[0], pl1[1]), (pr1[0], pr1[1]), (pr2[0], pr2[1])]
        listB = [(pl1[0], pl1[1]), (pl2[0], pl2[1]), (pr2[0], pr2[1])]

        pygame.draw.polygon(screen, szary, listA)
        pygame.draw.polygon(screen, szary, listB)

        t += res

    if(punktyDrogi):
        for node in track:
            pygame.draw.rect(screen, zielony, (node.x - 4, node.y - 4, 8, 8))


    if(srodekDrogi):
        t=0
        while t < float(len(track)):
            px = getSplinePoint(t, track);
            pygame.draw.rect(screen, bialy, (px[0] - 1, px[1] - 1, 2, 2))
            t+=0.005

    calcRacingLine()

    totalSplineLength = updateSplineProperties(racingLine)
    #print(totalSplineLength)

    if(drogaAuta):
        t = 0
        while t < float(len(racingLine)):
            px = getSplinePoint(t, racingLine);
            pygame.draw.rect(screen, niebieski, (px[0] - 1, px[1] - 1, 2, 2))
            t += 0.005

    #pygame.draw.lines(screen, czerwony, False, borderA, 1)
    #pygame.draw.line(screen, czerwony, borderA[-1], borderA[0])

    #pygame.draw.lines(screen, czerwony, False, borderB, 1)
    #pygame.draw.line(screen, czerwony, borderB[-1], borderB[0])

    car.update()

    if(wiodacy):
        pygame.draw.rect(screen, czerwony, (car.wiodacy[0], car.wiodacy[1], 5, 5))
    #screen.blit(car.image, car.rect)
    #f, FG_BLACK);
    """
    text1 = 'fMarker :' + str(fMarker)
    text2 = 'fOffset :' + str(fOffset)
    textsurface1 = myfont.render(text1, False, (91, 99, 210))
    textsurface2 = myfont.render(text2, False, (91, 99, 210))
    screen.blit(textsurface1, (0, 0))
    screen.blit(textsurface2, (0, 35))
    """

    pygame.display.flip()

    clock.tick(tick)
    timeCount = round(1000/tick)
    timeCount = 8


pygame.quit()
