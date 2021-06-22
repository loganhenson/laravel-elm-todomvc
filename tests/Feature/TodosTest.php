<?php

namespace Tests\Feature;

use App\Models\Todo;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TodosTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function can_create_todo()
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->post(route('todos.store'), [
                'description' => 'test',
            ])
            ->assertRedirect(route('home'));

        $this->assertDatabaseHas(Todo::class, [
            'user_id' => $user->id,
            'description' => 'test',
        ]);

        $this->get(route('home'))->assertJsonCount(1, 'props.todos');
    }

    /** @test */
    public function can_destroy_todo()
    {
        $user = User::factory()->create();
        $todo = Todo::factory()->for($user)->create();

        $this->actingAs($user)
            ->delete(route('todos.destroy', $todo->id))
            ->assertRedirect(route('home'));

        $this->assertDatabaseMissing(Todo::class, [
            'user_id' => $user->id,
            'description' => 'test',
        ]);

        $this->get(route('home'))->assertJsonCount(0, 'props.todos');
    }

    /** @test */
    public function can_update_todo_completed_state()
    {
        $user = User::factory()->create();
        $todo = Todo::factory()->for($user)->create();

        $this->actingAs($user)
            ->patch(route('todos.update', $todo->id), [
                'completed' => true,
            ])
            ->assertRedirect(route('home'));

        $this->assertDatabaseHas(Todo::class, [
            'user_id' => $user->id,
            'completed' => true,
        ]);

        $this->get(route('home'))->assertJsonCount(1, 'props.todos');
    }

    /** @test */
    public function can_update_todo_description()
    {
        $user = User::factory()->create();
        $todo = Todo::factory()->for($user)->create();

        $this->actingAs($user)
            ->patch(route('todos.update', $todo->id), [
                'description' => 'updated',
            ])
            ->assertRedirect(route('home'));

        $this->assertDatabaseHas(Todo::class, [
            'user_id' => $user->id,
            'description' => 'updated',
        ]);

        $this->get(route('home'))->assertJsonCount(1, 'props.todos');
    }
}
