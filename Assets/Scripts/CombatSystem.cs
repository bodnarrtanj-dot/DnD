using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Система бою для D&D механік
/// Підтримує покроковий бій з монстрами
/// </summary>
public class CombatSystem : MonoBehaviour
{
    [Header("Налаштування бою")]
    [SerializeField] private float turnDelay = 1f;
    
    public enum CombatState { Idle, PlayerTurn, EnemyTurn, Victory, Defeat }
    
    public CombatState currentState = CombatState.Idle;
    
    private PlayerController player;
    private Enemy currentEnemy;
    private List<Enemy> enemiesInCombat = new List<Enemy>();
    
    // Події для UI
    public static event System.Action<string> OnCombatMessage;
    public static event System.Action<int, int> OnHealthChanged;
    public static event System.Action OnCombatEnded;
    
    private void Awake()
    {
        player = FindObjectOfType<PlayerController>();
    }
    
    /// <summary>
    /// Почати бій з ворогом
    /// </summary>
    public void StartCombat(Enemy enemy)
    {
        currentEnemy = enemy;
        enemiesInCombat.Clear();
        enemiesInCombat.Add(enemy);
        currentState = CombatState.PlayerTurn;
        
        OnCombatMessage?.Invoke($", "overwrite": false}