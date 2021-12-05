using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BillBoard : MonoBehaviour
{
    Transform camTransform;

    Rigidbody rb;

    private void Awake() {
        camTransform = Camera.main.transform;
        rb = GetComponent<Rigidbody>();
    }

    private void LateUpdate() {
        var rb = GetComponent<Rigidbody>();
        if (rb && rb.IsSleeping()) return;
        var pos = transform.position;
        var dir = (pos - camTransform.position).normalized;
        var look = Quaternion.LookRotation(dir);
        transform.rotation = look;
    }
}
