/* The Computer Language Benchmarks Game
   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
   contributed by Ralph Ganszky
 
   CLBG version: Swift #6 simple program https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/nbody-swift-6.html
 
   modified by Anna Skantz
*/

import Foundation

class Body {
    var x: Double = 0.0
    var y: Double = 0.0
    var z: Double = 0.0
    var vx: Double = 0.0
    var vy: Double = 0.0
    var vz: Double = 0.0
    var mass: Double = 0.0
}

public class NBodyNative {
    
    let SOLAR_MASS = 4 * Double.pi * Double.pi
    let DAYS_PER_YEAR = 365.24
    
    public init() {}
    
    func jupiter() -> Body {
        let p = Body()
        p.x = 4.8414314424647209
        p.y = -1.16032004402742839
        p.z = -0.103622044471123109
        p.vx = 1.66007664274403694e-03 * DAYS_PER_YEAR
        p.vy = 7.69901118419740425e-03 * DAYS_PER_YEAR
        p.vz = -6.90460016972063023e-05 * DAYS_PER_YEAR
        p.mass = 9.54791938424326609e-04 * SOLAR_MASS
        return p
    }
    
    func saturn() -> Body {
        let p = Body()
        p.x = 8.34336671824457987
        p.y = 4.12479856412430479
        p.z = -4.03523417114321381e-01
        p.vx = -2.76742510726862411e-03 * DAYS_PER_YEAR
        p.vy = 4.99852801234917238e-03 * DAYS_PER_YEAR
        p.vz = 2.30417297573763929e-05 * DAYS_PER_YEAR
        p.mass = 2.85885980666130812e-04 * SOLAR_MASS
        return p
    }
    
    func uranus() -> Body {
        let p = Body()
        p.x = 1.28943695621391310e+01
        p.y = -1.51111514016986312e+01
        p.z = -2.23307578892655734e-01
        p.vx = 2.96460137564761618e-03 * DAYS_PER_YEAR
        p.vy = 2.37847173959480950e-03 * DAYS_PER_YEAR
        p.vz = -2.96589568540237556e-05 * DAYS_PER_YEAR
        p.mass = 4.36624404335156298e-05 * SOLAR_MASS
        return p
    }
    
    func neptune() -> Body {
        let p = Body()
        p.x = 1.53796971148509165e+01
        p.y = -2.59193146099879641e+01
        p.z = 1.79258772950371181e-01
        p.vx = 2.68067772490389322e-03 * DAYS_PER_YEAR
        p.vy = 1.62824170038242295e-03 * DAYS_PER_YEAR
        p.vz = -9.51592254519715870e-05 * DAYS_PER_YEAR
        p.mass = 5.15138902046611451e-05 * SOLAR_MASS
        return p
    }
    
    func sun() -> Body {
        let p = Body()
        p.mass = SOLAR_MASS
        return p
    }
    
    func advance(_ bodies: inout [Body], dt: Double) {
        for i in 0..<bodies.count {
            for j in i+1..<bodies.count {
                let (dx, dy, dz) = (bodies[i].x - bodies[j].x,
                                    bodies[i].y - bodies[j].y,
                                    bodies[i].z - bodies[j].z)
                
                let dSquared = dx*dx + dy*dy + dz*dz
                let distance = sqrt(dSquared)
                let mag = dt / (dSquared * distance)
                
                bodies[i].vx = bodies[i].vx - dx * bodies[j].mass * mag
                bodies[i].vy = bodies[i].vy - dy * bodies[j].mass * mag
                bodies[i].vz = bodies[i].vz - dz * bodies[j].mass * mag
                
                bodies[j].vx = bodies[j].vx + dx * bodies[i].mass * mag
                bodies[j].vy = bodies[j].vy + dy * bodies[i].mass * mag
                bodies[j].vz = bodies[j].vz + dz * bodies[i].mass * mag
            }
        }
        
        for i in 0..<bodies.count {
            bodies[i].x = bodies[i].x + dt * bodies[i].vx
            bodies[i].y = bodies[i].y + dt * bodies[i].vy
            bodies[i].z = bodies[i].z + dt * bodies[i].vz
        }
    }
    
    func energy(_ bodies: [Body]) -> Double {
        var energy = 0.0
        for (i, body) in bodies.enumerated() {
            energy += 0.5 * body.mass * ( body.vx*body.vx
                                       + body.vy*body.vy
                                       + body.vz*body.vz)
            for jbody in bodies[i+1..<bodies.count] {
                let dx = body.x - jbody.x
                let dy = body.y - jbody.y
                let dz = body.z - jbody.z
                let distance = sqrt(dx*dx + dy*dy + dz*dz)
                energy -= (body.mass * jbody.mass) / distance
            }
        }
        
        return energy
    }

    public func runBenchmark( n: Int) {
        var bodies = [sun(), jupiter(), saturn(), uranus(), neptune()]
        
        // Adjust to momentum of the sun
        var p = (0.0, 0.0, 0.0)
        for body in bodies {
            p.0 += body.vx * body.mass
            p.1 += body.vy * body.mass
            p.2 += body.vz * body.mass
        }
        bodies[0].vx = -p.0 / SOLAR_MASS
        bodies[0].vy = -p.1 / SOLAR_MASS
        bodies[0].vz = -p.2 / SOLAR_MASS
        
        let before = (round(energy(bodies) * 1000000000)/1000000000.0)
        print(before)
        
        for _ in 0..<n {
            advance(&bodies, dt: 0.01)
        }
        
        let after = (round(energy(bodies) * 1000000000)/1000000000.0)
        print(after)
    }
}
