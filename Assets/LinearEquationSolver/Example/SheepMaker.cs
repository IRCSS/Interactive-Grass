using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SheepMaker : MonoBehaviour {

    public static Material legsMat;
    public static Material bodyMat;

    private GameObject leftFront;
    private GameObject leftBack;
    private GameObject rightFront;
    private GameObject rightback;

    private GameObject head;

    private float timer;

    private Vector3 deltaMovement;
    private Vector3 prePositon;

    // Use this for initialization
    void Start () {
        if (legsMat == null) (legsMat = new Material( this.GetComponent<Renderer>().sharedMaterial)).color = new Color(0.6f, 0.4f, 0.0f);

        if (bodyMat == null) bodyMat = new Material(Shader.Find("Unlit/SheepFluff"));
        bodyMat.color = new Color(116f/255f, 116f / 255f, 116f / 255f);
        bodyMat.SetFloat("_TilingN1", 0.14f);
        bodyMat.SetFloat("_TilingN2", -0.1f);
        this.GetComponent<Renderer>().sharedMaterial = bodyMat;

        leftBack = SetupLeg();
        leftFront = SetupLeg();
        rightFront = SetupLeg();
        rightback = SetupLeg();

        float xzOffset = 0.35f;
        float yOffset = 0.65f;
        leftBack.transform.localPosition = new Vector3(-xzOffset, -yOffset, -xzOffset);
        leftFront.transform.localPosition = new Vector3(-xzOffset, -yOffset, xzOffset);
        rightFront.transform.localPosition = new Vector3(xzOffset, -yOffset, xzOffset);
        rightback.transform.localPosition = new Vector3(xzOffset, -yOffset, -xzOffset);

        head = GameObject.CreatePrimitive(PrimitiveType.Cube);
        head.GetComponent<Renderer>().sharedMaterial = this.GetComponent<Renderer>().sharedMaterial;
        head.transform.parent = this.transform;
        head.transform.localPosition = new Vector3(0f, 0.2f, 0.7f);
        head.transform.localScale = new Vector3(0.36f, 0.36f, 0.36f);

        //Traces collider
        GameObject tracesCollider = GameObject.CreatePrimitive(PrimitiveType.Cube);
        tracesCollider.gameObject.name = "tracesCollider";
        tracesCollider.transform.parent = this.transform;
        tracesCollider.transform.localPosition = new Vector3(0f, -yOffset, 0f);
        tracesCollider.transform.localScale = new Vector3(1.7f, 0.001f, 1.7f);
        tracesCollider.layer =  LayerMask.NameToLayer("Traces"); 

    }


    
    GameObject SetupLeg()
    {
        GameObject t = GameObject.CreatePrimitive(PrimitiveType.Cube);
        t.GetComponent<Renderer>().sharedMaterial = legsMat;
        t.transform.parent = this.transform;
        t.transform.localScale = new Vector3(0.2f, 0.5f, 0.2f);
        return t;
    
    }
	
	// Update is called once per frame
	void Update () {

        deltaMovement = this.transform.position - prePositon;
        prePositon = this.transform.position;


        if (deltaMovement.magnitude <= 0.0f) return;

        timer += Time.deltaTime;

        float rotateBatchOne = (Mathf.Abs(((timer * 1.5f %1)*2f)-1f)-0.5f)*4f ;
        Vector3 rotationCenter = leftBack.transform.localToWorldMatrix *  
            new Vector4(leftBack.transform.localPosition.x, leftBack.transform.localPosition.y+2.15f, leftBack.transform.localPosition.z,1f);

        leftBack.transform.RotateAround(rotationCenter, leftBack.transform.right, rotateBatchOne);
        rotationCenter = rightFront.transform.localToWorldMatrix *
            new Vector4(rightFront.transform.localPosition.x, rightFront.transform.localPosition.y + 2.15f, rightFront.transform.localPosition.z, 1f);
        rightFront.transform.RotateAround(rotationCenter, rightFront.transform.right, rotateBatchOne);

        float rotateBatchTwo = (Mathf.Abs((((timer * 1.5f+ 0.5f )% 1) * 2f) - 1f) - 0.5f) * 4f;

        rotationCenter = rightback.transform.localToWorldMatrix *
            new Vector4(rightback.transform.localPosition.x, rightback.transform.localPosition.y + 2.15f, rightback.transform.localPosition.z, 1f);

        rightback.transform.RotateAround(rotationCenter, rightback.transform.right, rotateBatchTwo);
        rotationCenter = leftFront.transform.localToWorldMatrix *
            new Vector4(leftFront.transform.localPosition.x, leftFront.transform.localPosition.y + 2.15f, leftFront.transform.localPosition.z, 1f);
        leftFront.transform.RotateAround(rotationCenter, leftFront.transform.right, rotateBatchTwo);

    }
}
