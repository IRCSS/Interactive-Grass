using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class Agent : MonoBehaviour {

    private Manager r_mg;
    public Vector2 velocity;
    public int confidence;
    private float maxSpeed = 0.01f;
    private Vector2 minMaxIntialSpeed = new Vector2(0.01f, 0.06f);
    private LinearEquationSolver l;
    private float thisAgentSpeed;
    private int indexInList;

    public void Inialiaze( Manager mg, int index )
    {
        this.gameObject.AddComponent<SheepMaker>();
        r_mg = mg;
        this.transform.position = mg.ReturnRandomPos()+ new Vector3(0f,this.transform.localScale.y, 0f);
        velocity = new Vector2(Random.Range(minMaxIntialSpeed.x, minMaxIntialSpeed.y) * (Random.value > 0.5?1f:-1f),  Random.Range(minMaxIntialSpeed.x, minMaxIntialSpeed.y)*(Random.value > 0.5 ? 1f : -1f));
        thisAgentSpeed = velocity.magnitude;
        maxSpeed = Random.Range(0.06f, 0.09f);
        indexInList = index;
        confidence = Random.Range(0, 10);

        GameObject g = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        g.transform.localScale = Vector3.one * 0.3f;
        g.layer = LayerMask.NameToLayer("Points");
        g.transform.parent = this.transform;
        g.transform.localPosition = Vector3.zero;
        g.GetComponent<Renderer>().material.color = new Color(Random.value, Random.value, Random.value);


    }

    private void Update()
    {
    
        for(uint i = 0; i < r_mg.NumberOfAgents; i++)
        {
            if (r_mg.allAgents[i] == this) continue;
            l = new LinearEquationSolver(new VectorLineEquation(new Vector2(this.transform.position.x, this.transform.position.z), velocity),
                new VectorLineEquation(new Vector2( r_mg.allAgents[i].transform.position.x, r_mg.allAgents[i].transform.position.z), r_mg.allAgents[i].velocity));
            if (l.isSolvable  && Mathf.Min(l.timeEquationOne, l.timeEquationTwo)>-30.0f)
            {
                if (!r_mg.IsWithinField(new Vector3(l.solution.x, this.transform.position.y, l.solution.y))) continue;

                float d = Vector3.Distance(transform.position, r_mg.allAgents[i].transform.position);
                d = 1.0f - Mathf.Clamp01(d / 5.0f);

                Vector3 agentToCurrent = (transform.position - r_mg.allAgents[i].transform.position).normalized;
                velocity += new Vector2(agentToCurrent.x, agentToCurrent.z) * d * 0.01f;

                if (Mathf.Abs(l.timeEquationOne - l.timeEquationTwo) > 120.2f)
                {
                    Debug.DrawLine(this.transform.position, new Vector3(l.solution.x, this.transform.position.y, l.solution.y));
                    continue;
                }
                
                if (confidence > r_mg.allAgents[i].confidence) continue;
                float movementStrenght = Mathf.SmoothStep(0.003f, 0.001f, Vector3.Distance(transform.position, r_mg.allAgents[i].transform.position)*0.1f);

                float decider = Mathf.Pow( (float)indexInList/ (float)r_mg.NumberOfAgents, (float)i/(float)r_mg.NumberOfAgents);

                Vector2 direction = new Vector2(transform.right.x, transform.right.z) * (decider > 0.5 ? 1f : -1f);

             
              
          
                velocity += direction.normalized * movementStrenght;
               
                Debug.DrawLine(this.transform.position, new Vector3(l.solution.x, this.transform.position.y, l.solution.y),d>0.5?Color.white: Color.red);



            }
        }

        velocity = Vector2.Lerp(Vector2.zero, velocity, 0.60f);

        Move();
    }

    private void Move()
    {
        Vector3 temp = this.transform.position;
       
        velocity += new Vector2(this.transform.forward.x, this.transform.forward.z) * thisAgentSpeed;
        velocity =Vector2.ClampMagnitude(velocity, maxSpeed);
        temp += new Vector3(velocity.x, 0f, velocity.y) ;

        r_mg.MirrorPosition(ref temp);
        this.transform.position = temp;
        this.transform.forward = new Vector3(velocity.x, 0f, velocity.y).normalized;
    }
}





