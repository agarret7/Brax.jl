import PyCall

brax = PyCall.pyimport("brax")
plt = PyCall.pyimport("matplotlib.pyplot")
matplotlib = PyCall.pyimport("matplotlib")
Line2D = matplotlib.lines.Line2D
Circle = matplotlib.patches.Circle
np = PyCall.pyimport("numpy")

bouncy_ball = brax.Config(dt=0.05, substeps=20, dynamics_mode="pbd")

# ground is a frozen (immovable) infinite plane
ground = bouncy_ball.bodies.add(name="ground")
ground.frozen.all = true
plane = ground.colliders.add().plane
plane.SetInParent()  # for setting an empty oneof

# ball weighs 1kg, has equal rotational inertia along all axes, is 1m long, and
# has an initial rotation of identity (w=1,x=0,y=0,z=0) quaternion
ball1 = bouncy_ball.bodies.add(name="ball1", mass=1)
ball2 = bouncy_ball.bodies.add(name="ball2", mass=1)
cap1 = ball1.colliders.add().capsule
cap2 = ball2.colliders.add().capsule
cap1.radius, cap1.length = 0.5, 1
cap2.radius, cap2.length = 0.5, 1

# gravity is -9.8 m/s^2 in z dimension
bouncy_ball.gravity.z = -9.8

qp = brax.QP(
    # position of each body in 3d (z is up, right-hand coordinates)
    pos = np.array([[0., 0., 0.],       # ground
                    [-2, 0., 3.],
                    [2, 0., 3.]]),     # ball is 3m up in the air
    # velocity of each body in 3d
    vel = np.array([[0., 0., 0.],       # ground
                    [0.75, 0., 0.],
                    [-0.75, 0., 0.]]),     # ball
    # rotation about center of body, as a quaternion (w, x, y, z)
    rot = np.array([[1., 0., 0., 0.],   # ground
                    [1., 0., 0., 0.],
                    [1., 0., 0., 0.]]), # ball
    # angular velocity about center of body in 3d
    ang = np.array([[0., 0., 0.],       # ground
                    [0., 0., 0.],
                    [0., 0., 0.]])      # ball
)
@show qp

function draw_system(ax, pos; alpha=1)
    for p in eachrow(pos)
        ax.add_patch(Circle(xy=(p[1], p[3]), radius=cap.radius, fill=false, color=(0, 0, 0, alpha)))
    end
end

#@title Simulating the bouncy ball config { run: "auto"}
bouncy_ball.elasticity = 0.85 #@param { type:"slider", min: 0, max: 1.0, step:0.05 }
ball_velocity = 1 #@param { type:"slider", min:-5, max:5, step: 0.5 }

sys = brax.System(bouncy_ball)

# provide an initial velocity to the ball
qp.vel[2, 1] = ball_velocity

_, ax = plt.subplots()
plt.xlim([-3, 3])
plt.ylim([0, 4])

for i in 1:100
    global qp
    draw_system(ax, qp.pos[2:end,:]; alpha=i/100.)
    qp, _ = sys.step(qp, [])
end

plt.title("2 balls colliding")
plt.show()