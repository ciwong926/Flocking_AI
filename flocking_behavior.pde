/**
 * Holds the radius and the forward offset of the 
 * wander circle
 */
float wanderOffset = 70;
float wanderRadius = 200;
/**
 * Holds the maximum rate at which the wander orientation 
 * can change.
 */
float wanderRate = 1;
/**
 * Holds the maximum acceleration of the character
 */
float maxAcceleration = 0.5;
/**
 *  Max acceleration speed of the character.
 */
float maxSpeed = 3.5;
/**
 * The size of the character that will be moving.
 */
float size = 15;
/**
 * Holds the radius for slowing down.
 */ 
float slowRadius = 0;
/**
 * Holds the time in which to keep the target 
 * speed.
 */
float timeToTarget = 0.1;
/**
 * Threshold to take action for seperation;
 */
float threshold = 60;
/*
 * Decay Variable k
 */
float k = 20; 

float idCount;


/**
 * Characters
 */
ArrayList<Character> characters;

/**
 * Funciton for setting up varaibles at the beganning of
 * the program.
 */
void setup() {
 
  size( 800, 800 ); 
  
  characters = new ArrayList<Character>();
  
  idCount = 0;
  
  characters.add( new Character(0, 0, idCount) );
  
  idCount++;
  
}  

/**
 * Responsible for graphics on the canvas.
 */
void draw() {
  
  // Establishing background color.
  background(25);
  
  for (int i = 0; i < characters.size(); i++ ) {
    characters.get(i).display();
  } 
     
}  
  
void mousePressed() {
  float x = mouseX;
  float y = mouseY;
  characters.add( new Character(x, y, idCount) );
  idCount++;
}

/**
 * Accepts radians and produces the vector version of 
 * it.
 */
PVector asVector( float angle ) {
  PVector ret = new PVector( 0, 0 );
  ret.x = sin(angle);
  ret.y = cos(angle);
  return ret;
}   
  
/**
 * A class that acts as a struct for holding 
 * kinematic variables. 
 */
class Kinematic {
  PVector velocity;
  PVector position;
  float orientation;
  float rotation; 
  
  public Kinematic() {
    velocity = new PVector(0, 0);
    position = new PVector(0, 0);
    orientation = 0;
    rotation = 0;
  }  
}

/**
 * A class that acts as a struct for holding
 * steering output.
 */
class SteeringOutput {
  PVector linAccel;
  float rotAccel;
  
  public SteeringOutput() {
    linAccel = new PVector(0, 0);
    rotAccel = 0;
  }  
}  

class CollisionDetector {
  
  
  public CollisionDetector( ) {
    // Nothing
  }  
  
  Collision getCollision( PVector position, PVector moveAmount ) {
    return new Collision(position, moveAmount);
  }
  
} 

class Collision {
  
  PVector normal;
  PVector position;
  float small;
  float distx;
  float disty;
  
  public Collision ( PVector position, PVector moveAmount ) {
    
    this.normal = new PVector( 0, 0 );
    this.position = new PVector( 0, 0 );
    this.small = 1000;
    
    if ( position.x + moveAmount.x > 800 ) {
      this.distx = 800 - position.x;
      float proportion = distx/moveAmount.x;
      float disty = moveAmount.y * proportion;
      if ( distx < small ) {
        this.small = distx;
        this.position.x = position.x + distx;
        this.position.y = position.y + disty;
        this.normal.x = -moveAmount.x;
        this.normal.y = 0;
      }  
    }  
    if ( position.x + moveAmount.x < 0 ) {
      this.distx = position.x;
      float proportion = distx/moveAmount.x;
      float disty = moveAmount.y * proportion;
      if ( distx < small ) {
        this.small = distx;
        this.position.x = position.x - distx;
        this.position.y = position.y - disty;
        this.normal.x = -moveAmount.x;
        this.normal.y = 0;
      }        
    } 
    if ( position.y + moveAmount.y > 800 ) {
      this.disty = 800 - position.y;
      float proportion = disty/moveAmount.y;
      float distx = moveAmount.x * proportion;
      if ( disty < small ) {
        this.small = disty;
        this.position.x = position.x + distx;
        this.position.y = position.y + disty;
        this.normal.y = -moveAmount.y;
        this.normal.x = 0;
      } 
    }  
    if ( position.y + moveAmount.y < 0 ) {
      print("got here");
      this.disty = position.y;
      float proportion = disty/moveAmount.y;
      float distx = moveAmount.x * proportion;
      if ( disty < small ) {
        this.small = disty;
        this.position.x = position.x - distx;
        this.position.y = position.y - disty;
        this.normal.y = -moveAmount.y;
        this.normal.x = 0;
      }                    
    }  
  
  } 
  
}  

class Character {
  
  Kinematic kin;
  Kinematic tar;
  
  float wanderOrientation;
  float distance;
  float minDist;
  
  float limit;
  boolean neg;
  float count;
  float zero;
  
  float id;
  
  public Character( float x , float y, float i ) {
    this.kin = new Kinematic();
    this.tar = new Kinematic();
    this.kin.position.x = x;
    this.kin.position.y = y;
    this.wanderOrientation = 0;
    this.distance = 0;
    this.minDist = 0;
    this.limit = 0;
    this.neg = false;
    this.count = 20;
    this.zero = 0.5;
    this.id = i;
  }
  
  void update() {
  
    // Get Acceleration Requests
    SteeringOutput out = getSteering();
  
    //character.velocity.add(out.linAccel);
    kin.velocity.x += out.linAccel.x;
    kin.velocity.y += out.linAccel.y;
  
    // Clip to max velocity
    if ( kin.velocity.mag() > maxSpeed ) {
       kin.velocity.normalize();
       kin.velocity.mult(maxAcceleration);
    }
    
    // Calculate new position.
    kin.position.x += kin.velocity.x;
    kin.position.y += kin.velocity.y; 
    
    // Adjust if past parameters.
    if ( kin.position.x > 800 ) {
      kin.position.x = 0;
    } 
    if ( kin.position.y > 800 ) {
      kin.position.y = 0;
    } 
    if ( kin.position.x < 0 ) {
      kin.position.x = 800;
    } 
    if ( kin.position.y < 0 ) {
      kin.position.y = 800;
    } 
    
    // Calculate orientation.
    if ( kin.velocity.x == 0 ) {
      kin.orientation = 0;
    } else {  
      kin.orientation = atan2( ( kin.velocity.y), kin.velocity.x);
    }       
  }
  
  /**
   * Implementation of Wander Algorithm from "Artificial Intellegence for Games" 2nd Ed. 
   * Ian Millington, John Funge - pg. 74
   */
  SteeringOutput getSteering() {
    
    // A structure for holding our output.
    SteeringOutput steering = new SteeringOutput();
    
    //// Prioritize avoiding walls
    //boolean avoided = avoidWalls();
    //if ( avoided ) {
    //  steering = seekPos( steering );
    //  return steering;
    //}  
    
    // Then seperating from other characters
    SteeringOutput steeringA = seperate( steering );

    //If seperation took place, prioritize it and return steering
    if ( steering.linAccel.x != 0 || steering.linAccel.y != 0 ) {
      return steeringA;
    }  
   
    // If there is only one character, wander.
    if ( characters.size() == 1 ) {
      wanderTarget();   
      steering = seekPos( steering );
      
    // Otherwise orient velocity and orientation.  
    } else {
      SteeringOutput steeringB = orient( new SteeringOutput() );
      SteeringOutput steeringC = centMass( new SteeringOutput() );
      steering.linAccel.x = ( steeringB.linAccel.x * 0.50) + ( steeringC.linAccel.x * 0.50 );
      steering.linAccel.y = ( steeringB.linAccel.y * 0.50) + ( steeringC.linAccel.x * 0.50 );
    }  
          
    return steering;   
    
  }  
  
  /**
   * Configure target to avoid walls
   */
  boolean avoidWalls() {
        
    // Create a collision detector 
    CollisionDetector cd = new CollisionDetector();
    // Establish lookahead distance
    float lookahead = 100;
    // Avoid distance
    float avoidDistance = 5;
    
    // Calulate the collision ray vector
    PVector rayVector = new PVector();
    rayVector.x = kin.velocity.x;
    rayVector.y = kin.velocity.y;
    rayVector.normalize();
    rayVector.mult(lookahead);
    
    // Find the collision
    Collision collision = cd.getCollision( kin.position, rayVector );
    
    if ( collision.small != 1000 ) {
      tar.position.x = collision.position.x + collision.normal.x * avoidDistance;
      tar.position.y = collision.position.y + collision.normal.y * avoidDistance;
 
      return true;
    }      
    
    return false;
  }  
  
  /**
   * Configure the target to be a wander target.
   */
  void wanderTarget() {
      // Update the wander orientation
      wanderOrientation += randomBinomial() * wanderRate;
  
      // Calculate the combined target orientation
      tar.orientation = wanderOrientation + kin.orientation;
  
      // Calculate the center of the wander circle 
      tar.position.x = kin.position.x + wanderOffset + asVector( kin.orientation ).x;
      tar.position.y = kin.position.y + wanderOffset + asVector( kin.orientation ).y;
  
      // Make sure wander circle is within bounds & clip if not
      if ( tar.position.x < wanderRadius + size ) {
        tar.position.x = wanderRadius + size;
      } 
      if ( tar.position.x > 800 - wanderRadius - size) {
        tar.position.x = 800 - wanderRadius - size;
      }  
      if ( tar.position.y < wanderRadius + size ) {
        tar.position.y = wanderRadius + size;
      } 
      if ( tar.position.y > 800 - wanderRadius - size ) {
        tar.position.y = 800 - wanderRadius - size;
      }  

      // Calculate the target location
      tar.position.x += wanderRadius * asVector( tar.orientation ).x;
      tar.position.y += wanderRadius * asVector( tar.orientation ).y;  
   } 
   
   /**
    * Tells the character to seek the configured target at a particular
    * position.
    */
   SteeringOutput seekPos( SteeringOutput steering ) {
     
     // Get the direction of the target  
     PVector directionOfTarget = new PVector( 0, 0 );
     directionOfTarget.x += tar.position.x;
     directionOfTarget.y += tar.position.y; 
     directionOfTarget.x -= kin.position.x;
     directionOfTarget.y -= kin.position.y;
  
     distance = directionOfTarget.mag();
  
     // The speed one should use to approach the target.
     float targetSpeed;
  
     // If we are outside the slowRadius, then go to max speed.
     if ( distance > slowRadius ) {
         targetSpeed = maxSpeed;
    
     // Otherwise calculate a scaled speed. 
     } else {
      targetSpeed = maxSpeed * distance / slowRadius;
     }  
  
     tar.velocity = directionOfTarget.normalize();
     tar.velocity.mult(targetSpeed);
    
     // Acceleration tries to get to the target velocity.
     steering.linAccel.x += tar.velocity.x;
     steering.linAccel.y += tar.velocity.y;
     steering.linAccel.x -= kin.velocity.x;
     steering.linAccel.y -= kin.velocity.y;
  
     steering.linAccel.div( timeToTarget );
  
     // Check if acceleration is too fast.
     if ( steering.linAccel.mag() > maxAcceleration ) {
       steering.linAccel.normalize();
       steering.linAccel.mult(maxAcceleration);
     }  
  
     return steering;
   }  
   
   /**
    * Seperates characters
    */
   SteeringOutput seperate( SteeringOutput steering ) {
     
     distance = threshold; 
     minDist = threshold;
     for (int i = 0; i < characters.size(); i++ ) {
      
       // Check if the target is close
       PVector dir = new PVector( 0, 0);
       dir.x = this.kin.position.x - characters.get(i).kin.position.x;
       dir.y = this.kin.position.y - characters.get(i).kin.position.y;
      
       float strength = 0;
      
       distance = dir.mag();
       if ( distance < minDist ) {
         minDist = distance;
       }  
       if ( distance < threshold && characters.get(i).id != this.id) {
        
         // Calculate the strength of repulsion
         
         //// Linear Seperation
         //strength = maxAcceleration * ( threshold - distance ) / threshold;
         
         // Inverse Square Law
         strength = min( k / (distance*distance), maxAcceleration );
        
         // Add the acceleration
         dir.normalize();
         steering.linAccel.x += strength * dir.x;
         steering.linAccel.y += strength * dir.y;        
       }       
    }         
     return steering;
   }  
   
   /** 
    * Orients orientation and velocity.
    */
   SteeringOutput orient( SteeringOutput steering ) {
      
      PVector avgVelocity = new PVector( 0, 0 );
      float avgOrientation = 0;
      
      for (int i = 0; i < characters.size(); i++ ) {
        
        if ( characters.get(i).id != this.id ) {
        
           avgVelocity.x += characters.get(i).kin.position.x;
           avgVelocity.y += characters.get(i).kin.position.y;
         
           avgOrientation += characters.get(i).kin.orientation;
        }
      }  
      
      avgVelocity.div( characters.size() - 1 );
      avgOrientation /= ( characters.size() - 1 );
      
      tar.orientation = avgOrientation;
      tar.velocity.x = avgVelocity.x;
      tar.velocity.y = avgVelocity.y;
      
      steering = seek( steering );
      
      return steering;
   }  
   
   /**
    * Delegate to center of mass.
    */
   SteeringOutput centMass( SteeringOutput steering ) {
     
     PVector avgPosition = new PVector(0, 0); 
     
     int count = 0;
     for (int i = 0; i < characters.size(); i++ ) {    
        if ( characters.get(i).id != this.id ) {
           if ( this.kin.position.x - characters.get(i).kin.position.x < 200 || this.kin.position.y - characters.get(i).kin.position.y < 200 ) {
             avgPosition.x += characters.get(i).kin.position.x;
             avgPosition.y += characters.get(i).kin.position.y;
             count++;
           } else if (characters.get(i).kin.position.x -  this.kin.position.x < 200 || characters.get(i).kin.position.y -  this.kin.position.y < 200  ) {
             avgPosition.x += characters.get(i).kin.position.x;
             avgPosition.y += characters.get(i).kin.position.y;
             count++;
           }  
        }
     }
    
     if ( count > 0 ) {
       avgPosition.div( count );
     }
     
     tar.position.x = avgPosition.x;
     tar.position.y = avgPosition.y;
     
     steering = seekPos( steering );
     return steering;
   }
  
  /**
   * Seek target velocity.
   */
  SteeringOutput seek( SteeringOutput steering ) {
    
     // Acceleration tries to get to the target velocity.
     steering.linAccel.x += tar.velocity.x;
     steering.linAccel.y += tar.velocity.y;
     steering.linAccel.x -= kin.velocity.x;
     steering.linAccel.y -= kin.velocity.y;
  
     steering.linAccel.div( timeToTarget );
  
     // Check if acceleration is too fast.
     if ( steering.linAccel.mag() > maxAcceleration ) {
       steering.linAccel.normalize();
       steering.linAccel.mult(maxAcceleration);
     }  
      
     return steering;
  }  
  
  /**
   * Returns a random floating point number in 
   * binomial fashion. 
   */
  float randomBinomial() {
  
    float ret = random(0.5) - random(0.5);
    
    // Case 1: A negative number is requested
    if ( ret < 0 ) {    
      // You are already negative
      if ( neg == true ) {    
        // simply add to limit
        limit++;     
      // You are positve and haven't hit limit requirement   
      } else if ( neg == false  && limit < count) {      
        // Stay positive
        ret *= -1;
        limit++;   
      // You are positve and have hit negative requirement   
      } else {      
        // You are safe to change, reset limit.
        neg = true;
        limit = 0;
      } 
    
    // Case 2: A positive number is requested  
    } else {    
      // You are already positive
      if ( neg == false ) {
        // simply add to limit
        limit++;     
      // You are negative and haven't hit limit requirement   
      } else if ( neg == true  && limit < count) {    
        // Stay negative
        ret *= -1;
        limit++;    
      // You are negative and have hit limit requirement   
      } else {      
        // You are safe to change, reset limit.
        neg = false;
        limit = 0;
      } 
    
    }  
  
    float rad = random(1.0);
    if ( rad < zero ) {
      ret = 0;
    }  
  
    return ret;  
  } 
  
  void display() {
    
    update();
    
    // Displays character at the appropriate location and orientation.
    pushMatrix();
      translate( kin.position.x, kin.position.y );
      rotate(kin.orientation);  
      fill(180);
      noStroke();
      ellipse(0, 0, size, size);
      triangle( 0 + size/3.5, 0 + size/2.5, 0 + size/3.5, 0 - size/2.5, 0 + size, 0);
    popMatrix();
  }  
  
}  
  
