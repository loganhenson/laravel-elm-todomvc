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
            'id' => $todo->id,
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

    /** @test */
    public function can_bulk_toggle()
    {
        $user = User::factory()->has(Todo::factory()->count(3))->create();

        $this->actingAs($user)
            ->post(route('todos.toggle-all'), [
                'completed' => true,
            ])
            ->assertRedirect(route('home'));

        $this->assertEquals(3, Todo::where('completed', true)->count());
    }

    /** @test */
    public function can_delete_complete()
    {
        $user = User::factory()->has(Todo::factory([
            'completed' => true,
        ])->count(3))->create();

        $this->actingAs($user)
            ->post(route('todos.delete-complete'))
            ->assertRedirect(route('home'));

        $this->assertDatabaseCount(Todo::class, 0);
    }
}
