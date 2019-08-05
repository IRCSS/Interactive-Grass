using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public struct Matrix2x2
{
    float[] members;



    public Matrix2x2(float[] terms)
    {
        members = new float[4];
        terms.CopyTo(members, 0);
    }
    public Matrix2x2(Matrix2x2 toCopy)
    {
        members = new float[4];
        toCopy.members.CopyTo(members, 0);
    }

    public Vector2 Solve(Vector2 rightHandSide)
    {
        if (!isSolvable())
        {
            Debug.LogWarning("The code Attemped to solve an unsolvable Equation. " +
                "Check for singularity before attempting to solve, object: " + this);
            return Vector3.zero;
        }

        return Inverse() * rightHandSide;
    }

    public bool isSolvable()
    {
        float determinat = GetMemberAt(0, 0) * GetMemberAt(1, 1) - GetMemberAt(0, 1) * GetMemberAt(1, 0);
        // Case there are either no solution, or infinte amound of solutions
        if (determinat == 0) return false;
        // There is one Unique solution
        return true;
    }

    public float GetMemberAt(int i, int j)
    {
        if (Mathf.Max(i, j) >= 2)
        {
            Debug.LogError("Illegal memory access attempt at " + i + " row, " + j + "column. Object: " + this);
            return 0;
        }
        return members[2 * i + j];
    }
    public void SetMemberAt(int i, int j, float value)
    {
        if (Mathf.Max(i, j) >= 2)
        {
            Debug.LogError("Illegal memory access attempt at " + i + " row, " + j + "column. Object: " + this);
            return;
        }

        members[2 * i + j] = value;
    }

    public Matrix2x2 Inverse()
    {
        Matrix2x2 inverse = new Matrix2x2(this);
        inverse.SetMemberAt(0, 0, GetMemberAt(1, 1));
        inverse.SetMemberAt(1, 1, GetMemberAt(0, 0));
        inverse.SetMemberAt(0, 1, GetMemberAt(0, 1) * -1f);
        inverse.SetMemberAt(1, 0, GetMemberAt(1, 0) * -1f);

        float determinat = 1.0f / (GetMemberAt(0, 0) * GetMemberAt(1, 1) - GetMemberAt(0, 1) * GetMemberAt(1, 0));
        return determinat * inverse;
    }

    public Vector2 ReturnRow(int rowindex)
    {
        if (rowindex < 2 && rowindex >= 0) return new Vector2(GetMemberAt(rowindex, 0), GetMemberAt(rowindex, 1));
        Debug.LogError("Illegal memory access attempt at " + rowindex + " row, " + ". Object: " + this);
        return Vector2.zero;

    }

    public Vector2 ReturnColumn(int columnindex)
    {
        if (columnindex < 2 && columnindex >= 0) return new Vector2(GetMemberAt(0, columnindex), GetMemberAt(0, columnindex));
        Debug.LogError("Illegal memory access attempt at " + columnindex + " row, " + ". Object: " + this);
        return Vector2.zero;
    }

    public static Matrix2x2 operator *(Matrix2x2 lhs, Matrix2x2 rhs)
    {
        Matrix2x2 t = new Matrix2x2(new float[] { 0f, 0f, 0f, 0f });

        t.SetMemberAt(0, 0, Vector2.Dot(lhs.ReturnRow(0), rhs.ReturnColumn(0)));
        t.SetMemberAt(0, 1, Vector2.Dot(lhs.ReturnRow(0), rhs.ReturnColumn(1)));
        t.SetMemberAt(1, 0, Vector2.Dot(lhs.ReturnRow(1), rhs.ReturnColumn(0)));
        t.SetMemberAt(1, 1, Vector2.Dot(lhs.ReturnRow(1), rhs.ReturnColumn(1)));

        return t;
    }

    public static Vector2 operator *(Matrix2x2 lhs, Vector2 rhs)
    {
        return new Vector2(Vector2.Dot(lhs.ReturnRow(0), rhs), Vector2.Dot(lhs.ReturnRow(1), rhs));
    }

    public static Matrix2x2 operator *(float scalar, Matrix2x2 rhs)
    {
        for (int i = 0; i < 2; i++)
        {
            for (int j = 0; j < 2; j++)
            {
                rhs.SetMemberAt(i, j, rhs.GetMemberAt(i, j) * scalar);
            }
        }
        return rhs;
    }

    public override string ToString()
    {
        return "{ " + GetMemberAt(0, 0) + "," + GetMemberAt(0, 1) + "," + GetMemberAt(1, 0) + "," + GetMemberAt(1, 1) + "}";
    }

}
