using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Manager : MonoBehaviour {

    public uint NumberOfAgents;
    public Agent[] allAgents;
    

    void Start () {
        allAgents = new Agent[NumberOfAgents];
        for(uint i = 0; i<allAgents.Length; i++)
        {
            allAgents[i] = GameObject.CreatePrimitive(PrimitiveType.Cube).AddComponent<Agent>();
            allAgents[i].Inialiaze(this,(int)i);
        }

    }

    public Vector3 ReturnRandomPos()
    {
        return transform.localToWorldMatrix *new Vector4(Random.value*10f - 5f, 0f, Random.value*10f - 5f, 1f) ;
    }

    

    public bool MirrorPosition(ref Vector3 posToMirror)
    {
        Vector3 temp = posToMirror;
        temp = transform.worldToLocalMatrix * new Vector4(temp.x, temp.y, temp.z, 1f);
        if(Mathf.Max(Mathf.Max(Mathf.Abs( temp.x), Mathf.Abs (temp.y)), Mathf.Abs(temp.z)) <5f) return false;
        posToMirror = transform.localToWorldMatrix* new Vector4(temp.x * -1f, temp.y, temp.z * -1f, 1f);
        return true;
    }

    public bool IsWithinField( Vector3 posTocheck)
    {
        Vector3 temp = posTocheck;
        temp = transform.worldToLocalMatrix * new Vector4(temp.x, temp.y, temp.z, 1f);
        if (Mathf.Max(Mathf.Max(Mathf.Abs(temp.x), Mathf.Abs(temp.y)), Mathf.Abs(temp.z)) < 5f) return true;
        return false;
    }
	
}
