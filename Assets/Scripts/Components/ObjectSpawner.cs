using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;

public class ObjectSpawner : MonoBehaviour
{
    [SerializeField]
    GameObject prefab;

    [SerializeField]
    Vector2 scaleMinMax;

    [SerializeField]
    int maxAmount;

    [SerializeField]
    float spawnDelay;

    int amount;

    private void Start() {
        SpawnWithDelay();
    }


    private async void SpawnWithDelay ()
    {
        var exitT = Time.time + spawnDelay;
        while(Time.time < exitT) {
            await Task.Yield();
        }
        if (amount++ < maxAmount) {
            var inst = Instantiate(prefab);
            var instTf = inst.transform;
            var rb = inst.AddComponent<Rigidbody>();
            instTf.position = transform.position;
            instTf.localScale *= Mathf.Lerp(scaleMinMax.x, scaleMinMax.y, Random.value);
            rb.AddForce(Random.insideUnitSphere * .1f);
            rb.sleepThreshold = 150f;
            rb.drag = .7f;
            SpawnWithDelay();
        }
    }
}
