using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// ------------------------------ LINEAR EQUATION SYSTEM SOLVER. ---------------------------------------------

public struct CartesianLineEquation
{
    // For y = mx +c where m is gradient and c is y axis interesction
    public float yInteresect, gradient;
    public CartesianLineEquation(float yInt, float g)
    {
        yInteresect = yInt;
        gradient = g;
    }

    public override string ToString()
    {
        return "y-Intersect is: " + yInteresect + ", gradient is: " + gradient;
    }
}

public struct VectorLineEquation
{
    // For vR = vPos + t*vDirection. 
    public Vector2 Pos, direction;
    public float directionMag;
    public VectorLineEquation(Vector2 pPos, Vector2 pDirection)
    {
        Pos = pPos;
        directionMag = pDirection.magnitude;
        direction = pDirection.normalized;
    }

    // for y = mx +c, m is deltaY/deltaX, and c you get from subtituting the Pos in the equation
    // c = y -mx
    public CartesianLineEquation ToCartesian()
    {

        float gradient = direction.y / direction.x;
        float c = -gradient * Pos.x + Pos.y;
        return new CartesianLineEquation(c, gradient);
    }

    // for    1:  t = (vR.x-vPos.x)/vDirection.x
    //        2:  t = (vR.y-vPos.y)/vDirection.y
    //        3:   (vR.x-vPos.x)/vDirection.x = (vR.y-vPos.y)/vDirection.y
    public bool CalculateT(Vector2 Point, ref float solution)
    {
        float rhs = (Point.x - Pos.x) / (direction.x * directionMag);
        float lhs = (Point.y - Pos.y) / (direction.y * directionMag);
        if (Mathf.Abs(rhs - lhs) < 0.001f)
        {
            solution = rhs;
            return true;
        }
        return false;
    }

    public override string ToString()
    {
        return "position is: " + Pos + ", direction is: " + direction + ", direction Magnitude was: " + directionMag;
    }

}

public class LinearEquationSolver
{
    public VectorLineEquation m_vEqOne, m_vEqTwo;
    public CartesianLineEquation m_cEqOne, m_cEqTwo;

    public Matrix2x2 equationMatrix;
    public bool isSolvable;
    public Vector2 solution;
    public float timeEquationOne, timeEquationTwo;

    bool debug = false;

    public LinearEquationSolver(VectorLineEquation equationOne, VectorLineEquation equationTwo)
    {
        UpdateTheEquation(equationOne, equationTwo);
    }

    public void UpdateTheEquation(VectorLineEquation equationOne, VectorLineEquation equationTwo)
    {
        m_vEqOne = equationOne;
        m_vEqTwo = equationTwo;


        m_cEqOne = m_vEqOne.ToCartesian();
        m_cEqTwo = m_vEqTwo.ToCartesian();

        if (debug)
        {
            Debug.Log("equation one Vector form: " + m_vEqOne.ToString());
            Debug.Log("equation one Cartesian form: " + m_cEqOne.ToString());

            Debug.Log("equation Two Vector form: " + m_vEqTwo.ToString());
            Debug.Log("equation Two Cartesian form: " + m_cEqTwo.ToString());
        }



        // Construct the Matrix.
        equationMatrix = CartianToMatrix();

        if (debug)
            Debug.Log("matrix construction: " + equationMatrix.ToString());

        if (!equationMatrix.isSolvable())
        {
            isSolvable = false;

            return;
        }
        isSolvable = true;
        solution = equationMatrix.Solve(new Vector2(m_cEqOne.yInteresect, m_cEqTwo.yInteresect));


        // Calculate the t for the direction vector of each equation
        m_vEqOne.CalculateT(solution, ref timeEquationOne);
        m_vEqTwo.CalculateT(solution, ref timeEquationTwo);

    }

    public Matrix2x2 CartianToMatrix()
    {
        return new Matrix2x2(new float[] { -m_cEqOne.gradient, 1f, -m_cEqTwo.gradient, 1f });
    }
}
