using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[InitializeOnLoad]
public class CaptureSheepMovement : MonoBehaviour {

    public int TextureResolution = 512;
    public RenderTexture rt,  depthTexture,  temp;
    private Camera cm;

    private Material mergeMt;
    public Shader depthPass, tracesPass, mergerPass;
    public static CaptureSheepMovement s;
    static CaptureSheepMovement()
    {
        EditorApplication.update += EditorUpdate;
    }

    public CaptureSheepMovement()
    {
        s = this;
    }

    static void EditorUpdate()
    {
        if (s != null)
            s.SetupCamera();
    }
	// Use this for initialization
	void Start () {
    
        SetupCamera();


    }

    private void Update()
    {

      
        PopulateRenderTextures();
    }

    void SetupCamera()
    {
        if (cm != null) return;
        cm = this.GetComponent<Camera>();
        if (cm == null) Debug.LogWarning("No camera Attached to the game object: " + this.gameObject.name);
        cm.aspect = 1f;
        rt = new RenderTexture(TextureResolution, TextureResolution, 16, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
        Shader.SetGlobalTexture("_TracesCamTex", rt);
        Shader.SetGlobalTexture("_TracesCamDepth", depthTexture);
        Shader.SetGlobalTexture("_TracesIntermidate", temp);
        mergerPass = Shader.Find("Passes/MergePass");
        mergeMt = new Material(mergerPass);
        depthPass = Shader.Find("Unlit/DepthPass");
        tracesPass = Shader.Find("Unlit/TracePass");

        depthTexture = new RenderTexture(rt);
        depthTexture.format = RenderTextureFormat.RFloat;
        temp = new RenderTexture(rt);
        Matrix4x4 worldToCamMatrix = cm.projectionMatrix * cm.worldToCameraMatrix;
        Shader.SetGlobalMatrix("_TracesWorldToViewMatrix", worldToCamMatrix);
        PopulateRenderTextures();


    }

    void PopulateRenderTextures()
    {
        // Depth pass on the top down camera
        cm.cullingMask = 1 << LayerMask.NameToLayer("InteractiveGrass");
        cm.targetTexture = depthTexture;
        cm.RenderWithShader(depthPass, "");

        // Traces pass, render all objects that are supposed to leave a trace behind
        cm.cullingMask = 1 << LayerMask.NameToLayer("Traces");
        cm.targetTexture = temp;
        cm.RenderWithShader(tracesPass, "");

        // Combine the two map for collision detection and 
        RenderTexture r = RenderTexture.GetTemporary(rt.descriptor);
        // copy over to a temp for double buffering
        Graphics.Blit(rt, r);
        mergeMt.SetTexture("_TracesCamDepth", depthTexture);
        mergeMt.SetTexture("_TracesIntermidate", temp);
        Graphics.Blit(r, rt, mergeMt,0);
        r.Release();
    }


	
}
